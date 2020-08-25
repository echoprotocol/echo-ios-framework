//
//  AssetsFacadeImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 04.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public struct AssetsServices {
    var databaseService: DatabaseApiService
    var networkBroadcastService: NetworkBroadcastApiService
}

/**
    Implementation of [AssetsFacade](AssetsFacade),[ECHOQueueble](ECHOQueueble)
*/
final public class AssetsFacadeImp: AssetsFacade, ECHOQueueble, NoticeEventDelegate {
    public var queues: [String: ECHOQueue]
    let services: AssetsServices
    let cryptoCore: CryptoCoreComponent
    let network: ECHONetwork
    let transactionExpirationOffset: TimeInterval
    
    private enum CreateAssetKeys: String {
        case account
        case operation
        case fee
        case blockData
        case chainId
        case transaction
    }
    
    private enum IssueAssetKeys: String {
        case issuerAccount
        case destinationAccount
        case operation
        case fee
        case blockData
        case chainId
        case transaction
    }
    
    public init(services: AssetsServices,
                cryptoCore: CryptoCoreComponent,
                network: ECHONetwork,
                noticeDelegateHandler: NoticeEventDelegateHandler,
                transactionExpirationOffset: TimeInterval) {
        
        self.services = services
        self.cryptoCore = cryptoCore
        self.network = network
        self.transactionExpirationOffset = transactionExpirationOffset
        self.queues = [String: ECHOQueue]()
        noticeDelegateHandler.delegate = self
    }
    
    public func createAsset(
        nameOrId: String,
        wif: String,
        asset: Asset,
        sendCompletion: @escaping Completion<Void>,
        confirmNoticeHandler: NoticeHandler?
    ) {

        let createAssetQueue = ECHOQueue()
        addQueue(createAssetQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(nameOrId, CreateAssetKeys.account.rawValue)])
        let getAccountsOperationInitParams = (createAssetQueue,
                                             services.databaseService,
                                             getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<Void>(initParams: getAccountsOperationInitParams,
                                                                  completion: sendCompletion)
        
        // Operation
        let createAssetOperation = self.createAssetOperation(createAssetQueue, asset, sendCompletion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (createAssetQueue,
                                                 services.databaseService,
                                                 Asset(Settings.defaultAsset),
                                                 CreateAssetKeys.operation.rawValue,
                                                 CreateAssetKeys.fee.rawValue,
                                                 UInt(1))
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<Void>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: sendCompletion)
        
        // ChainId
        let getChainIdInitParams = (createAssetQueue, services.databaseService, CreateAssetKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<Void>(initParams: getChainIdInitParams,
                                                                 completion: sendCompletion)
        
        // BlockData
        let getBlockDataInitParams = (createAssetQueue, services.databaseService, CreateAssetKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<Void>(initParams: getBlockDataInitParams,
                                                                     completion: sendCompletion)
        
        // Transaciton
        let transactionOperationInitParams = (queue: createAssetQueue,
                                              cryptoCore: cryptoCore,
                                              saveKey: CreateAssetKeys.transaction.rawValue,
                                              wif: wif,
                                              networkPrefix: network.echorandPrefix.rawValue,
                                              fromAccountKey: CreateAssetKeys.account.rawValue,
                                              operationKey: CreateAssetKeys.operation.rawValue,
                                              chainIdKey: CreateAssetKeys.chainId.rawValue,
                                              blockDataKey: CreateAssetKeys.blockData.rawValue,
                                              feeKey: CreateAssetKeys.fee.rawValue,
                                              expirationOffset: transactionExpirationOffset)
        let bildTransactionOperation = GetTransactionQueueOperation<Void>(initParams: transactionOperationInitParams,
                                                                          completion: sendCompletion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (createAssetQueue,
                                                 services.networkBroadcastService,
                                                 EchoQueueMainKeys.operationId.rawValue,
                                                 CreateAssetKeys.transaction.rawValue)
        let sendTransactionOperation = SendTransactionQueueOperation(initParams: sendTransacionOperationInitParams,
                                                                     completion: sendCompletion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: createAssetQueue)
        
        createAssetQueue.addOperation(getAccountsOperation)
        createAssetQueue.addOperation(createAssetOperation)
        createAssetQueue.addOperation(getRequiredFeeOperation)
        createAssetQueue.addOperation(getChainIdOperation)
        createAssetQueue.addOperation(getBlockDataOperation)
        createAssetQueue.addOperation(bildTransactionOperation)
        createAssetQueue.addOperation(sendTransactionOperation)
        
        //Notice handler
        if let noticeHandler = confirmNoticeHandler {
            createAssetQueue.saveValue(noticeHandler, forKey: EchoQueueMainKeys.noticeHandler.rawValue)
            
            let waitingOperationParams = (
                createAssetQueue,
                EchoQueueMainKeys.notice.rawValue,
                EchoQueueMainKeys.noticeError.rawValue
            )
            let waitOperation = WaitQueueOperation(initParams: waitingOperationParams)
            
            let noticeHadleOperaitonParams = (
                createAssetQueue,
                EchoQueueMainKeys.notice.rawValue,
                EchoQueueMainKeys.noticeError.rawValue,
                EchoQueueMainKeys.noticeHandler.rawValue
            )
            let noticeHandleOperation = NoticeHandleQueueOperation(initParams: noticeHadleOperaitonParams)
            
            createAssetQueue.addOperation(waitOperation)
            createAssetQueue.addOperation(noticeHandleOperation)
        }
        
        createAssetQueue.addOperation(completionOperation)
    }
    
    // swiftlint:disable function_body_length
    public func issueAsset(
        issuerNameOrId: String,
        wif: String,
        asset: String,
        amount: UInt,
        destinationIdOrName: String,
        sendCompletion: @escaping Completion<Void>,
        confirmNoticeHandler: NoticeHandler?
    ) {
        // Validate asset id
        do {
            let validator = IdentifierValidator()
            try validator.validateId(asset, for: .asset)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<Void, ECHOError>(error: echoError)
            sendCompletion(result)
            return
        }
        
        let issueAssetQueue = ECHOQueue()
        addQueue(issueAssetQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(issuerNameOrId, IssueAssetKeys.issuerAccount.rawValue),
                                                                          (destinationIdOrName, IssueAssetKeys.destinationAccount.rawValue)])
        let getAccountsOperationInitParams = (issueAssetQueue,
                                             services.databaseService,
                                             getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<Void>(initParams: getAccountsOperationInitParams,
                                                                  completion: sendCompletion)
        
        // Operation
        let createIssueAssetOperation = self.createIssueAssetOperation(issueAssetQueue, amount, asset, sendCompletion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (issueAssetQueue,
                                                 services.databaseService,
                                                 Asset(Settings.defaultAsset),
                                                 IssueAssetKeys.operation.rawValue,
                                                 IssueAssetKeys.fee.rawValue,
                                                 UInt(1))
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<Void>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: sendCompletion)
        
        // ChainId
        let getChainIdInitParams = (issueAssetQueue, services.databaseService, IssueAssetKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<Void>(initParams: getChainIdInitParams,
                                                                 completion: sendCompletion)
        
        // BlockData
        let getBlockDataInitParams = (issueAssetQueue, services.databaseService, CreateAssetKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<Void>(initParams: getBlockDataInitParams,
                                                                     completion: sendCompletion)
        
        // Transaciton
        let transactionOperationInitParams = (queue: issueAssetQueue,
                                              cryptoCore: cryptoCore,
                                              saveKey: IssueAssetKeys.transaction.rawValue,
                                              wif: wif,
                                              networkPrefix: network.echorandPrefix.rawValue,
                                              fromAccountKey: IssueAssetKeys.issuerAccount.rawValue,
                                              operationKey: IssueAssetKeys.operation.rawValue,
                                              chainIdKey: IssueAssetKeys.chainId.rawValue,
                                              blockDataKey: IssueAssetKeys.blockData.rawValue,
                                              feeKey: IssueAssetKeys.fee.rawValue,
                                              expirationOffset: transactionExpirationOffset)
        let bildTransactionOperation = GetTransactionQueueOperation<Void>(initParams: transactionOperationInitParams,
                                                                          completion: sendCompletion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (issueAssetQueue,
                                                 services.networkBroadcastService,
                                                 EchoQueueMainKeys.operationId.rawValue,
                                                 IssueAssetKeys.transaction.rawValue)
        let sendTransactionOperation = SendTransactionQueueOperation(initParams: sendTransacionOperationInitParams,
                                                                     completion: sendCompletion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: issueAssetQueue)
        
        issueAssetQueue.addOperation(getAccountsOperation)
        issueAssetQueue.addOperation(createIssueAssetOperation)
        issueAssetQueue.addOperation(getRequiredFeeOperation)
        issueAssetQueue.addOperation(getChainIdOperation)
        issueAssetQueue.addOperation(getBlockDataOperation)
        issueAssetQueue.addOperation(bildTransactionOperation)
        issueAssetQueue.addOperation(sendTransactionOperation)
        
        //Notice handler
        if let noticeHandler = confirmNoticeHandler {
            issueAssetQueue.saveValue(noticeHandler, forKey: EchoQueueMainKeys.noticeHandler.rawValue)
            
            let waitingOperationParams = (
                issueAssetQueue,
                EchoQueueMainKeys.notice.rawValue,
                EchoQueueMainKeys.noticeError.rawValue
            )
            let waitOperation = WaitQueueOperation(initParams: waitingOperationParams)
            
            let noticeHadleOperaitonParams = (
                issueAssetQueue,
                EchoQueueMainKeys.notice.rawValue,
                EchoQueueMainKeys.noticeError.rawValue,
                EchoQueueMainKeys.noticeHandler.rawValue
            )
            let noticeHandleOperation = NoticeHandleQueueOperation(initParams: noticeHadleOperaitonParams)
            
            issueAssetQueue.addOperation(waitOperation)
            issueAssetQueue.addOperation(noticeHandleOperation)
        }
        
        issueAssetQueue.addOperation(completionOperation)
    }
    // swiftlint:enable function_body_length
    
    public func listAssets(lowerBound: String, limit: Int, completion: @escaping Completion<[Asset]>) {
        services.databaseService.listAssets(lowerBound: lowerBound, limit: limit, completion: completion)
    }
    
    public func getAsset(assetIds: [String], completion: @escaping Completion<[Asset]>) {
        
        // Validate assetIds
        do {
            let validator = IdentifierValidator()
            for identifier in assetIds {
                try validator.validateId(identifier, for: .asset)
            }
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<[Asset], ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        services.databaseService.getAssets(assetIds: assetIds, completion: completion)
    }
    
    fileprivate func createIssueAssetOperation(_ queue: ECHOQueue,
                                               _ amount: UInt,
                                               _ asset: String,
                                               _ completion: @escaping Completion<Void>) -> Operation {
        
        let createIssueAssetOperation = BlockOperation()
        
        createIssueAssetOperation.addExecutionBlock { [weak createIssueAssetOperation, weak self, weak queue] in
            
            guard createIssueAssetOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let issuerAccount: Account = queue?.getValue(IssueAssetKeys.issuerAccount.rawValue) else { return }
            guard let destinationAccount: Account = queue?.getValue(IssueAssetKeys.destinationAccount.rawValue) else { return }
            
            let fee = AssetAmount(amount: 0, asset: Asset(Settings.defaultAsset))
            let assetToIssue = AssetAmount(amount: amount, asset: Asset(asset))
            
            let operation = IssueAssetOperation(issuer: issuerAccount,
                                                assetToIssue: assetToIssue,
                                                issueToAccount: destinationAccount,
                                                fee: fee)
            
            queue?.saveValue(operation, forKey: IssueAssetKeys.operation.rawValue)
        }
        
        return createIssueAssetOperation
    }
    
    fileprivate func createAssetOperation(_ queue: ECHOQueue,
                                          _ asset: Asset,
                                          _ completion: @escaping Completion<Void>) -> Operation {
        
        let createAssetOperation = BlockOperation()
        
        createAssetOperation.addExecutionBlock { [weak createAssetOperation, weak self, weak queue] in
            
            guard createAssetOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            
            let fee = AssetAmount(amount: 0, asset: Asset(Settings.defaultAsset))
            let operation = CreateAssetOperation(asset: asset, fee: fee)
            
            queue?.saveValue(operation, forKey: CreateAssetKeys.operation.rawValue)
        }
        
        return createAssetOperation
    }
}
