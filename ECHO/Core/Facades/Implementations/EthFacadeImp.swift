//
//  EthFacadeImp.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 20/05/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
 Services for TransactionFacade
 */
public struct EthFacadeServices {
    var databaseService: DatabaseApiService
    var networkBroadcastService: NetworkBroadcastApiService
}

/**
 Implementation of [EthFacade](EthFacade), [ECHOQueueble](ECHOQueueble)
 */
final public class EthFacadeImp: EthFacade, ECHOQueueble {

    var queues: [ECHOQueue]
    let services: EthFacadeServices
    let network: ECHONetwork
    let cryptoCore: CryptoCoreComponent
    
    public init(services: EthFacadeServices,
                cryptoCore: CryptoCoreComponent,
                network: ECHONetwork,
                noticeDelegateHandler: NoticeEventDelegateHandler) {
        
        self.services = services
        self.network = network
        self.cryptoCore = cryptoCore
        self.queues = [ECHOQueue]()
        noticeDelegateHandler.delegate = self
    }
    
    public func getEthAddress(nameOrId: String, completion: @escaping Completion<EthAddress?>) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrId], shoudSubscribe: false) { [weak self] (result) in
            
            switch result {
            case .success(let accounts):
                guard let account = accounts[nameOrId] else {
                    let result = Result<EthAddress?, ECHOError>(error: .resultNotFound)
                    completion(result)
                    return
                }
                
                self?.services.databaseService.getEthAddress(accountId: account.account.id, completion: completion)
            case .failure(let error):
                let result = Result<EthAddress?, ECHOError>(error: error)
                completion(result)
            }
        }
    }
    
    public func getAccountDeposits(nameOrId: String, completion: @escaping Completion<[DepositEth]>) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrId], shoudSubscribe: false) { [weak self] (result) in
            
            switch result {
            case .success(let accounts):
                guard let account = accounts[nameOrId] else {
                    let result = Result<[DepositEth], ECHOError>(error: .resultNotFound)
                    completion(result)
                    return
                }
                
                self?.services.databaseService.getAccountDeposits(accountId: account.account.id,
                                                                  completion: completion)
            case .failure(let error):
                let result = Result<[DepositEth], ECHOError>(error: error)
                completion(result)
            }
        }
    }
    
    public func getAccountWithdrawals(nameOrId: String, completion: @escaping Completion<[WithdrawalEth]>) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrId], shoudSubscribe: false) { [weak self] (result) in
            
            switch result {
            case .success(let accounts):
                guard let account = accounts[nameOrId] else {
                    let result = Result<[WithdrawalEth], ECHOError>(error: .resultNotFound)
                    completion(result)
                    return
                }
                
                self?.services.databaseService.getAccountWithdrawals(accountId: account.account.id,
                                                                     completion: completion)
            case .failure(let error):
                let result = Result<[WithdrawalEth], ECHOError>(error: error)
                completion(result)
            }
        }
    }
    
    private enum EthFacadeResultKeys: String {
        case loadedAccount
        case blockData
        case chainId
        case operation
        case fee
        case transaction
        case operationId
        case notice
        case noticeHandler
    }
    
    // swiftlint:disable function_body_length
    public func generateEthAddress(nameOrId: String,
                                   wif: String,
                                   assetForFee: String?,
                                   completion: @escaping Completion<Bool>,
                                   noticeHandler: NoticeHandler?) {
        
        // if we don't hace assetForFee, we use asset.
        let assetForFee = assetForFee ?? Settings.defaultAsset
        
        // Validate asset id
        do {
            let validator = IdentifierValidator()
            try validator.validateId(assetForFee, for: .asset)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<Bool, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        let generateQueue = ECHOQueue()
        queues.append(generateQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(nameOrId, EthFacadeResultKeys.loadedAccount.rawValue)])
        let getAccountsOperationInitParams = (generateQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<Bool>(initParams: getAccountsOperationInitParams,
                                                                   completion: completion)
        
        let bildTransferOperation = createBildGenerationOperation(generateQueue, Asset(assetForFee), completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (generateQueue,
                                                 services.databaseService,
                                                 Asset(assetForFee),
                                                 EthFacadeResultKeys.operation.rawValue,
                                                 EthFacadeResultKeys.fee.rawValue,
                                                 UInt(1))
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<Bool>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: completion)
        
        // ChainId
        let getChainIdInitParams = (generateQueue, services.databaseService, EthFacadeResultKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<Bool>(initParams: getChainIdInitParams,
                                                                 completion: completion)
        
        // BlockData
        let getBlockDataInitParams = (generateQueue, services.databaseService, EthFacadeResultKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<Bool>(initParams: getBlockDataInitParams,
                                                                     completion: completion)
        
        // Transaciton
        let transactionOperationInitParams = (queue: generateQueue,
                                              cryptoCore: cryptoCore,
                                              saveKey: EthFacadeResultKeys.transaction.rawValue,
                                              wif: wif,
                                              networkPrefix: network.echorandPrefix.rawValue,
                                              fromAccountKey: EthFacadeResultKeys.loadedAccount.rawValue,
                                              operationKey: EthFacadeResultKeys.operation.rawValue,
                                              chainIdKey: EthFacadeResultKeys.chainId.rawValue,
                                              blockDataKey: EthFacadeResultKeys.blockData.rawValue,
                                              feeKey: EthFacadeResultKeys.fee.rawValue)
        let bildTransactionOperation = GetTransactionQueueOperation<Bool>(initParams: transactionOperationInitParams,
                                                                          completion: completion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (generateQueue,
                                                 services.networkBroadcastService,
                                                 EthFacadeResultKeys.operationId.rawValue,
                                                 EthFacadeResultKeys.transaction.rawValue)
        let sendTransactionOperation = SendTransactionQueueOperation(initParams: sendTransacionOperationInitParams,
                                                                     completion: completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: generateQueue)
        
        generateQueue.addOperation(getAccountsOperation)
        generateQueue.addOperation(bildTransferOperation)
        generateQueue.addOperation(getRequiredFeeOperation)
        generateQueue.addOperation(getChainIdOperation)
        generateQueue.addOperation(getBlockDataOperation)
        generateQueue.addOperation(bildTransactionOperation)
        generateQueue.addOperation(sendTransactionOperation)
        
        //Notice handler
        if let noticeHandler = noticeHandler {
            generateQueue.saveValue(noticeHandler, forKey: EthFacadeResultKeys.noticeHandler.rawValue)
            let waitOperation = createWaitingOperation(generateQueue)
            let noticeHandleOperation = createNoticeHandleOperation(generateQueue,
                                                                    EthFacadeResultKeys.noticeHandler.rawValue,
                                                                    EthFacadeResultKeys.notice.rawValue)
            generateQueue.addOperation(waitOperation)
            generateQueue.addOperation(noticeHandleOperation)
        }
        
        generateQueue.setCompletionOperation(completionOperation)
    }
    
    public func withdrawalEth(nameOrId: String,
                              wif: String,
                              toEthAddress: String,
                              amount: UInt,
                              assetForFee: String?,
                              completion: @escaping Completion<Bool>,
                              noticeHandler: NoticeHandler?) {
        
        // if we don't hace assetForFee, we use asset.
        let assetForFee = assetForFee ?? Settings.defaultAsset
        
        // Validate asset id
        do {
            let validator = IdentifierValidator()
            try validator.validateId(assetForFee, for: .asset)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<Bool, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        let ethValidator = ETHAddressValidator(cryptoCore: cryptoCore)
        guard ethValidator.isValidETHAddress(toEthAddress) else {
            let result = Result<Bool, ECHOError>(error: .invalidETHAddress)
            completion(result)
            return
        }
        
        let withdrawalQueue = ECHOQueue()
        queues.append(withdrawalQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(nameOrId, EthFacadeResultKeys.loadedAccount.rawValue)])
        let getAccountsOperationInitParams = (withdrawalQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<Bool>(initParams: getAccountsOperationInitParams,
                                                                   completion: completion)
        
        let bildTransferOperation = createBildWithdrawalOperation(withdrawalQueue, Asset(assetForFee), amount, toEthAddress, completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (withdrawalQueue,
                                                 services.databaseService,
                                                 Asset(assetForFee),
                                                 EthFacadeResultKeys.operation.rawValue,
                                                 EthFacadeResultKeys.fee.rawValue,
                                                 UInt(1))
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<Bool>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: completion)
        
        // ChainId
        let getChainIdInitParams = (withdrawalQueue, services.databaseService, EthFacadeResultKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<Bool>(initParams: getChainIdInitParams,
                                                                 completion: completion)
        
        // BlockData
        let getBlockDataInitParams = (withdrawalQueue, services.databaseService, EthFacadeResultKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<Bool>(initParams: getBlockDataInitParams,
                                                                     completion: completion)
        
        // Transaciton
        let transactionOperationInitParams = (queue: withdrawalQueue,
                                              cryptoCore: cryptoCore,
                                              saveKey: EthFacadeResultKeys.transaction.rawValue,
                                              wif: wif,
                                              networkPrefix: network.echorandPrefix.rawValue,
                                              fromAccountKey: EthFacadeResultKeys.loadedAccount.rawValue,
                                              operationKey: EthFacadeResultKeys.operation.rawValue,
                                              chainIdKey: EthFacadeResultKeys.chainId.rawValue,
                                              blockDataKey: EthFacadeResultKeys.blockData.rawValue,
                                              feeKey: EthFacadeResultKeys.fee.rawValue)
        let bildTransactionOperation = GetTransactionQueueOperation<Bool>(initParams: transactionOperationInitParams,
                                                                          completion: completion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (withdrawalQueue,
                                                 services.networkBroadcastService,
                                                 EthFacadeResultKeys.operationId.rawValue,
                                                 EthFacadeResultKeys.transaction.rawValue)
        let sendTransactionOperation = SendTransactionQueueOperation(initParams: sendTransacionOperationInitParams,
                                                                     completion: completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: withdrawalQueue)
        
        withdrawalQueue.addOperation(getAccountsOperation)
        withdrawalQueue.addOperation(bildTransferOperation)
        withdrawalQueue.addOperation(getRequiredFeeOperation)
        withdrawalQueue.addOperation(getChainIdOperation)
        withdrawalQueue.addOperation(getBlockDataOperation)
        withdrawalQueue.addOperation(bildTransactionOperation)
        withdrawalQueue.addOperation(sendTransactionOperation)
        
        //Notice handler
        if let noticeHandler = noticeHandler {
            withdrawalQueue.saveValue(noticeHandler, forKey: EthFacadeResultKeys.noticeHandler.rawValue)
            let waitOperation = createWaitingOperation(withdrawalQueue)
            let noticeHandleOperation = createNoticeHandleOperation(withdrawalQueue,
                                                                    EthFacadeResultKeys.noticeHandler.rawValue,
                                                                    EthFacadeResultKeys.notice.rawValue)
            withdrawalQueue.addOperation(waitOperation)
            withdrawalQueue.addOperation(noticeHandleOperation)
        }
        
        withdrawalQueue.setCompletionOperation(completionOperation)
    }
    // swiftlint:enable function_body_length
    
    fileprivate func createBildGenerationOperation(_ queue: ECHOQueue,
                                                   _ asset: Asset,
                                                   _ completion: @escaping Completion<Bool>) -> Operation {
        
        let bildTransferOperation = BlockOperation()
        
        bildTransferOperation.addExecutionBlock { [weak bildTransferOperation, weak queue] in
            
            guard bildTransferOperation?.isCancelled == false else { return }
            
            guard let account: Account = queue?.getValue(EthFacadeResultKeys.loadedAccount.rawValue) else { return }
            
            let fee = AssetAmount(amount: 0, asset: asset)
            
            let extractedExpr: SidechainETHCreateAddressOperation = SidechainETHCreateAddressOperation.init(account: account, fee: fee)
            let transferOperation = extractedExpr
            
            queue?.saveValue(transferOperation, forKey: EthFacadeResultKeys.operation.rawValue)
        }
        
        return bildTransferOperation
    }
    
    fileprivate func createBildWithdrawalOperation(_ queue: ECHOQueue,
                                                   _ asset: Asset,
                                                   _ amount: UInt,
                                                   _ toEthAddress: String,
                                                   _ completion: @escaping Completion<Bool>) -> Operation {
        
        let bildWithdrawalOperation = BlockOperation()
        
        bildWithdrawalOperation.addExecutionBlock { [weak bildWithdrawalOperation, weak queue] in
            
            guard bildWithdrawalOperation?.isCancelled == false else { return }
            
            guard let account: Account = queue?.getValue(EthFacadeResultKeys.loadedAccount.rawValue) else { return }
            
            let fee = AssetAmount(amount: 0, asset: asset)
            let address = toEthAddress.replacingOccurrences(of: "0x", with: "")
            
            let extractedExpr: SidechainETHWithdrawOperation = SidechainETHWithdrawOperation(account: account,
                                                                               value: amount,
                                                                               ethAddress: address,
                                                                               fee: fee)
            let withdrawalOperation = extractedExpr
            
            queue?.saveValue(withdrawalOperation, forKey: EthFacadeResultKeys.operation.rawValue)
        }
        
        return bildWithdrawalOperation
    }
    
    fileprivate func createNoticeHandleOperation(_ queue: ECHOQueue,
                                                 _ noticeHandlerKey: String,
                                                 _ noticeKey: String) -> Operation {
        
        let noticeOperation = BlockOperation()
        
        noticeOperation.addExecutionBlock { [weak noticeOperation, weak queue, weak self] in
            
            guard noticeOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let noticeHandler: NoticeHandler = queue?.getValue(noticeHandlerKey) else { return }
            guard let notice: ECHONotification = queue?.getValue(noticeKey) else { return }
            
            noticeHandler(notice)
        }
        
        return noticeOperation
    }
    
    fileprivate func createWaitingOperation(_ queue: ECHOQueue) -> Operation {
        
        let waitingOperation = BlockOperation()
        
        waitingOperation.addExecutionBlock { [weak waitingOperation, weak queue, weak self] in
            
            guard waitingOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            queue?.waitStartNextOperation()
        }
        
        return waitingOperation
    }
}

extension EthFacadeImp: NoticeEventDelegate {
    
    public func didReceiveNotification(notification: ECHONotification) {
        
        switch notification.params {
        case .array(let array):
            if let noticeOperationId = array.first as? Int {
                
                for queue in queues {
                    
                    if let queueTransferOperationId: Int = queue.getValue(EthFacadeResultKeys.operationId.rawValue),
                        queueTransferOperationId == noticeOperationId {
                        queue.saveValue(notification, forKey: EthFacadeResultKeys.notice.rawValue)
                        queue.startNextOperation()
                    }
                }
            }
        default:
            break
        }
    }
}
