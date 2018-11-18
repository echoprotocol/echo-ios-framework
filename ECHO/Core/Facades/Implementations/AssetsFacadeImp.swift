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
final public class AssetsFacadeImp: AssetsFacade, ECHOQueueble {
    
    var queues: [ECHOQueue]
    let services: AssetsServices
    let cryptoCore: CryptoCoreComponent
    let network: ECHONetwork
    
    private enum CreateAssetKeys: String {
        case account
        case operation
        case fee
        case blockData
        case chainId
        case transaction
        case operationId
    }
    
    private enum IssueAssetKeys: String {
        case issuerAccount
        case destinationAccount
        case operation
        case fee
        case blockData
        case chainId
        case transaction
        case operationId
        case memo
    }
    
    public init(services: AssetsServices, cryptoCore: CryptoCoreComponent, network: ECHONetwork) {
        
        self.services = services
        self.cryptoCore = cryptoCore
        self.network = network
        self.queues = [ECHOQueue]()
    }
    
    public func createAsset(nameOrId: String, password: String, asset: Asset, completion: @escaping Completion<Bool>) {
        
        let createAssetQueue = ECHOQueue()
        queues.append(createAssetQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(nameOrId, CreateAssetKeys.account.rawValue)])
        let getAccountsOperationInitParams = (createAssetQueue,
                                             services.databaseService,
                                             getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<Bool>(initParams: getAccountsOperationInitParams,
                                                                  completion: completion)
        
        // Operation
        let createAssetOperation = self.createAssetOperation(createAssetQueue, asset, completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (createAssetQueue,
                                                 services.databaseService,
                                                 Asset(Settings.defaultAsset),
                                                 CreateAssetKeys.operation.rawValue,
                                                 CreateAssetKeys.fee.rawValue)
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<Bool>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: completion)
        
        // ChainId
        let getChainIdInitParams = (createAssetQueue, services.databaseService, CreateAssetKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<Bool>(initParams: getChainIdInitParams,
                                                                 completion: completion)
        
        // BlockData
        let getBlockDataInitParams = (createAssetQueue, services.databaseService, CreateAssetKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<Bool>(initParams: getBlockDataInitParams,
                                                                     completion: completion)
        
        // Transaciton
        let transactionOperationInitParams = (queue: createAssetQueue,
                                              cryptoCore: cryptoCore,
                                              keychainType: KeychainType.active,
                                              saveKey: CreateAssetKeys.transaction.rawValue,
                                              password: password,
                                              networkPrefix: network.prefix.rawValue,
                                              fromAccountKey: CreateAssetKeys.account.rawValue,
                                              operationKey: CreateAssetKeys.operation.rawValue,
                                              chainIdKey: CreateAssetKeys.chainId.rawValue,
                                              blockDataKey: CreateAssetKeys.blockData.rawValue,
                                              feeKey: CreateAssetKeys.fee.rawValue)
        let bildTransactionOperation = GetTransactionQueueOperation<Bool>(initParams: transactionOperationInitParams,
                                                                          completion: completion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (createAssetQueue,
                                                 services.networkBroadcastService,
                                                 CreateAssetKeys.operationId.rawValue,
                                                 CreateAssetKeys.transaction.rawValue)
        let sendTransactionOperation = SendTransactionQueueOperation(initParams: sendTransacionOperationInitParams,
                                                                     completion: completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: createAssetQueue)
        
        createAssetQueue.addOperation(getAccountsOperation)
        createAssetQueue.addOperation(createAssetOperation)
        createAssetQueue.addOperation(getRequiredFeeOperation)
        createAssetQueue.addOperation(getChainIdOperation)
        createAssetQueue.addOperation(getBlockDataOperation)
        createAssetQueue.addOperation(bildTransactionOperation)
        createAssetQueue.addOperation(sendTransactionOperation)
        
        createAssetQueue.setCompletionOperation(completionOperation)
    }
    
    // swiftlint:disable function_body_length
    public func issueAsset(issuerNameOrId: String, password: String,
                           asset: String, amount: UInt,
                           destinationIdOrName: String, message: String?,
                           completion: @escaping Completion<Bool>) {
        
        // Validate asset id
        do {
            let validator = IdentifierValidator()
            try validator.validateId(asset, for: .asset)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<Bool, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        let issueAssetQueue = ECHOQueue()
        queues.append(issueAssetQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(issuerNameOrId, IssueAssetKeys.issuerAccount.rawValue),
                                                                          (destinationIdOrName, IssueAssetKeys.destinationAccount.rawValue)])
        let getAccountsOperationInitParams = (issueAssetQueue,
                                             services.databaseService,
                                             getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<Bool>(initParams: getAccountsOperationInitParams,
                                                                  completion: completion)
        
        // Memo
        let getMemoOperationInitParams = (queue: issueAssetQueue,
                                          cryptoCore: cryptoCore,
                                          message: message,
                                          saveKey: IssueAssetKeys.memo.rawValue,
                                          password: password,
                                          networkPrefix: network.prefix.rawValue,
                                          fromAccountKey: IssueAssetKeys.issuerAccount.rawValue,
                                          toAccountKey: IssueAssetKeys.destinationAccount.rawValue)
        let getMemoOperation = GetMemoQueueOperation<Bool>(initParams: getMemoOperationInitParams,
                                                           completion: completion)
        
        // Operation
        let createIssueAssetOperation = self.createIssueAssetOperation(issueAssetQueue, password, amount, asset, message, completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (issueAssetQueue,
                                                 services.databaseService,
                                                 Asset(Settings.defaultAsset),
                                                 IssueAssetKeys.operation.rawValue,
                                                 IssueAssetKeys.fee.rawValue)
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<Bool>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: completion)
        
        // ChainId
        let getChainIdInitParams = (issueAssetQueue, services.databaseService, IssueAssetKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<Bool>(initParams: getChainIdInitParams,
                                                                 completion: completion)
        
        // BlockData
        let getBlockDataInitParams = (issueAssetQueue, services.databaseService, CreateAssetKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<Bool>(initParams: getBlockDataInitParams,
                                                                     completion: completion)
        
        // Transaciton
        let transactionOperationInitParams = (queue: issueAssetQueue,
                                              cryptoCore: cryptoCore,
                                              keychainType: KeychainType.active,
                                              saveKey: IssueAssetKeys.transaction.rawValue,
                                              password: password,
                                              networkPrefix: network.prefix.rawValue,
                                              fromAccountKey: IssueAssetKeys.issuerAccount.rawValue,
                                              operationKey: IssueAssetKeys.operation.rawValue,
                                              chainIdKey: IssueAssetKeys.chainId.rawValue,
                                              blockDataKey: IssueAssetKeys.blockData.rawValue,
                                              feeKey: IssueAssetKeys.fee.rawValue)
        let bildTransactionOperation = GetTransactionQueueOperation<Bool>(initParams: transactionOperationInitParams,
                                                                          completion: completion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (issueAssetQueue,
                                                 services.networkBroadcastService,
                                                 IssueAssetKeys.operationId.rawValue,
                                                 IssueAssetKeys.transaction.rawValue)
        let sendTransactionOperation = SendTransactionQueueOperation(initParams: sendTransacionOperationInitParams,
                                                                     completion: completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: issueAssetQueue)
        
        issueAssetQueue.addOperation(getAccountsOperation)
        issueAssetQueue.addOperation(getMemoOperation)
        issueAssetQueue.addOperation(createIssueAssetOperation)
        issueAssetQueue.addOperation(getRequiredFeeOperation)
        issueAssetQueue.addOperation(getChainIdOperation)
        issueAssetQueue.addOperation(getBlockDataOperation)
        issueAssetQueue.addOperation(bildTransactionOperation)
        issueAssetQueue.addOperation(sendTransactionOperation)
        
        issueAssetQueue.setCompletionOperation(completionOperation)
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
                                               _ password: String,
                                               _ amount: UInt,
                                               _ asset: String,
                                               _ message: String?,
                                               _ completion: @escaping Completion<Bool>) -> Operation {
        
        let createIssueAssetOperation = BlockOperation()
        
        createIssueAssetOperation.addExecutionBlock { [weak createIssueAssetOperation, weak self, weak queue] in
            
            guard createIssueAssetOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let issuerAccount: Account = queue?.getValue(IssueAssetKeys.issuerAccount.rawValue) else { return }
            guard let destinationAccount: Account = queue?.getValue(IssueAssetKeys.destinationAccount.rawValue) else { return }
            guard let memo: Memo = queue?.getValue(IssueAssetKeys.memo.rawValue) else { return }
            
            let fee = AssetAmount(amount: 0, asset: Asset(Settings.defaultAsset))
            let assetToIssue = AssetAmount(amount: amount, asset: Asset(asset))
            
            let operation = IssueAssetOperation(issuer: issuerAccount,
                                                assetToIssue: assetToIssue,
                                                issueToAccount: destinationAccount,
                                                fee: fee,
                                                memo: memo)
            
            queue?.saveValue(operation, forKey: IssueAssetKeys.operation.rawValue)
        }
        
        return createIssueAssetOperation
    }
    
    fileprivate func createAssetOperation(_ queue: ECHOQueue,
                                          _ asset: Asset,
                                          _ completion: @escaping Completion<Bool>) -> Operation {
        
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
