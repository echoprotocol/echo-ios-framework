//
//  BtcFacadeImp.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 28.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
 Services for BtcFacade
 */
public struct BtcFacadeServices {
    var databaseService: DatabaseApiService
    var networkBroadcastService: NetworkBroadcastApiService
}

/**
 Implementation of [BtcFacade](BtcFacade), [ECHOQueueble](ECHOQueueble)
 */
final public class BtcFacadeImp: BtcFacade, ECHOQueueble {
    var queues: [String: ECHOQueue]
    let services: BtcFacadeServices
    let network: ECHONetwork
    let cryptoCore: CryptoCoreComponent
    let transactionExpirationOffset: TimeInterval
    
    public init(services: BtcFacadeServices,
                cryptoCore: CryptoCoreComponent,
                network: ECHONetwork,
                noticeDelegateHandler: NoticeEventDelegateHandler,
                transactionExpirationOffset: TimeInterval) {
        
        self.services = services
        self.network = network
        self.cryptoCore = cryptoCore
        self.transactionExpirationOffset = transactionExpirationOffset
        self.queues = [String: ECHOQueue]()
        noticeDelegateHandler.delegate = self
    }
    
    public func getBtcAddress(nameOrId: String, completion: @escaping Completion<BtcAddress?>) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrId], shoudSubscribe: false) { [weak self] (result) in
            
            switch result {
            case .success(let accounts):
                guard let account = accounts[nameOrId] else {
                    let result = Result<BtcAddress?, ECHOError>(error: .resultNotFound)
                    completion(result)
                    return
                }
                
                self?.services.databaseService.getBtcAddress(accountId: account.account.id, completion: completion)
            case .failure(let error):
                let result = Result<BtcAddress?, ECHOError>(error: error)
                completion(result)
            }
        }
    }
    
    public func getBtcAccountDeposits(nameOrId: String, completion: @escaping Completion<[BtcDeposit]>) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrId], shoudSubscribe: false) { [weak self] (result) in
            
            switch result {
            case .success(let accounts):
                guard let account = accounts[nameOrId] else {
                    let result = Result<[BtcDeposit], ECHOError>(error: .resultNotFound)
                    completion(result)
                    return
                }
                
                self?.services.databaseService.getAccountDeposits(accountId: account.account.id,
                                                                  type: .btc,
                                                                  completion: { result in
                    switch result {
                    case .success(let sidechainEnums):
                        var deposits = [BtcDeposit]()
                        sidechainEnums.forEach {
                            switch $0 {
                            case .eth:
                                return
                            case .btc(let deposit):
                                deposits.append(deposit)
                            }
                        }
                        
                        let result = Result<[BtcDeposit], ECHOError>(value: deposits)
                        completion(result)
                        
                    case .failure(let error):
                        let result = Result<[BtcDeposit], ECHOError>(error: error)
                        completion(result)
                    }
                })
                
            case .failure(let error):
                let result = Result<[BtcDeposit], ECHOError>(error: error)
                completion(result)
            }
        }
    }
    
    public func getBtcAccountWithdrawals(nameOrId: String, completion: @escaping Completion<[BtcWithdrawal]>) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrId], shoudSubscribe: false) { [weak self] (result) in
            
            switch result {
            case .success(let accounts):
                guard let account = accounts[nameOrId] else {
                    let result = Result<[BtcWithdrawal], ECHOError>(error: .resultNotFound)
                    completion(result)
                    return
                }
                
                self?.services.databaseService.getAccountWithdrawals(accountId: account.account.id,
                                                                     type: .btc,
                                                                     completion: { result in
                    switch result {
                    case .success(let sidechainEnums):
                        var withdrawals = [BtcWithdrawal]()
                        sidechainEnums.forEach {
                            switch $0 {
                            case .eth:
                                return
                            case .btc(let withdrawal):
                                withdrawals.append(withdrawal)
                            }
                        }
                        
                        let result = Result<[BtcWithdrawal], ECHOError>(value: withdrawals)
                        completion(result)
                        
                    case .failure(let error):
                        let result = Result<[BtcWithdrawal], ECHOError>(error: error)
                        completion(result)
                    }
                })
                
            case .failure(let error):
                let result = Result<[BtcWithdrawal], ECHOError>(error: error)
                completion(result)
            }
        }
    }
    
    private enum BtcFacadeResultKeys: String {
        case loadedAccount
        case blockData
        case chainId
        case operation
        case fee
        case transaction
        case operationId
        case notice
        case noticeError
        case noticeHandler
    }
    
    // swiftlint:disable function_body_length
    public func generateBtcAddress(nameOrId: String,
                                   wif: String,
                                   backupAddress: String,
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
        
        let btcValidator = BTCAddressValidator(cryptoCore: cryptoCore)
        guard btcValidator.isValidBTCAddress(backupAddress) else {
            let result = Result<Bool, ECHOError>(error: .invalidBTCAddress)
            completion(result)
            return
        }
        
        let generateQueue = ECHOQueue()
        addQueue(generateQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(nameOrId, BtcFacadeResultKeys.loadedAccount.rawValue)])
        let getAccountsOperationInitParams = (generateQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<Bool>(initParams: getAccountsOperationInitParams,
                                                                   completion: completion)
        
        let bildTransferOperation = createBildGenerationOperation(generateQueue, backupAddress, Asset(assetForFee), completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (generateQueue,
                                                 services.databaseService,
                                                 Asset(assetForFee),
                                                 BtcFacadeResultKeys.operation.rawValue,
                                                 BtcFacadeResultKeys.fee.rawValue,
                                                 UInt(1))
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<Bool>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: completion)
        
        // ChainId
        let getChainIdInitParams = (generateQueue, services.databaseService, BtcFacadeResultKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<Bool>(initParams: getChainIdInitParams,
                                                                 completion: completion)
        
        // BlockData
        let getBlockDataInitParams = (generateQueue, services.databaseService, BtcFacadeResultKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<Bool>(initParams: getBlockDataInitParams,
                                                                     completion: completion)
        
        // Transaciton
        let transactionOperationInitParams = (queue: generateQueue,
                                              cryptoCore: cryptoCore,
                                              saveKey: BtcFacadeResultKeys.transaction.rawValue,
                                              wif: wif,
                                              networkPrefix: network.echorandPrefix.rawValue,
                                              fromAccountKey: BtcFacadeResultKeys.loadedAccount.rawValue,
                                              operationKey: BtcFacadeResultKeys.operation.rawValue,
                                              chainIdKey: BtcFacadeResultKeys.chainId.rawValue,
                                              blockDataKey: BtcFacadeResultKeys.blockData.rawValue,
                                              feeKey: BtcFacadeResultKeys.fee.rawValue,
                                              expirationOffset: transactionExpirationOffset)
        let bildTransactionOperation = GetTransactionQueueOperation<Bool>(initParams: transactionOperationInitParams,
                                                                          completion: completion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (generateQueue,
                                                 services.networkBroadcastService,
                                                 BtcFacadeResultKeys.operationId.rawValue,
                                                 BtcFacadeResultKeys.transaction.rawValue)
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
            generateQueue.saveValue(noticeHandler, forKey: BtcFacadeResultKeys.noticeHandler.rawValue)
            let waitOperation = createWaitingOperation(generateQueue)
            let noticeHandleOperation = createNoticeHandleOperation(generateQueue,
                                                                    BtcFacadeResultKeys.noticeHandler.rawValue,
                                                                    BtcFacadeResultKeys.notice.rawValue,
                                                                    BtcFacadeResultKeys.noticeError.rawValue)
            generateQueue.addOperation(waitOperation)
            generateQueue.addOperation(noticeHandleOperation)
        }
        
        generateQueue.addOperation(completionOperation)
    }
    // swiftlint:enable function_body_length
    
    // swiftlint:disable function_body_length
    public func withdrawBtc(nameOrId: String,
                            wif: String,
                            toBtcAddress: String,
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
        
        let btcValidator = BTCAddressValidator(cryptoCore: cryptoCore)
        guard btcValidator.isValidBTCAddress(toBtcAddress) else {
            let result = Result<Bool, ECHOError>(error: .invalidBTCAddress)
            completion(result)
            return
        }
        
        let withdrawalQueue = ECHOQueue()
        addQueue(withdrawalQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(nameOrId, BtcFacadeResultKeys.loadedAccount.rawValue)])
        let getAccountsOperationInitParams = (withdrawalQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<Bool>(initParams: getAccountsOperationInitParams,
                                                                   completion: completion)
        
        let bildTransferOperation = createBildWithdrawalOperation(withdrawalQueue, Asset(assetForFee), amount, toBtcAddress, completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (withdrawalQueue,
                                                 services.databaseService,
                                                 Asset(assetForFee),
                                                 BtcFacadeResultKeys.operation.rawValue,
                                                 BtcFacadeResultKeys.fee.rawValue,
                                                 UInt(1))
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<Bool>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: completion)
        
        // ChainId
        let getChainIdInitParams = (withdrawalQueue, services.databaseService, BtcFacadeResultKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<Bool>(initParams: getChainIdInitParams,
                                                                 completion: completion)
        
        // BlockData
        let getBlockDataInitParams = (withdrawalQueue, services.databaseService, BtcFacadeResultKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<Bool>(initParams: getBlockDataInitParams,
                                                                     completion: completion)
        
        // Transaciton
        let transactionOperationInitParams = (queue: withdrawalQueue,
                                              cryptoCore: cryptoCore,
                                              saveKey: BtcFacadeResultKeys.transaction.rawValue,
                                              wif: wif,
                                              networkPrefix: network.echorandPrefix.rawValue,
                                              fromAccountKey: BtcFacadeResultKeys.loadedAccount.rawValue,
                                              operationKey: BtcFacadeResultKeys.operation.rawValue,
                                              chainIdKey: BtcFacadeResultKeys.chainId.rawValue,
                                              blockDataKey: BtcFacadeResultKeys.blockData.rawValue,
                                              feeKey: BtcFacadeResultKeys.fee.rawValue,
                                              expirationOffset: transactionExpirationOffset)
        let bildTransactionOperation = GetTransactionQueueOperation<Bool>(initParams: transactionOperationInitParams,
                                                                          completion: completion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (withdrawalQueue,
                                                 services.networkBroadcastService,
                                                 BtcFacadeResultKeys.operationId.rawValue,
                                                 BtcFacadeResultKeys.transaction.rawValue)
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
            withdrawalQueue.saveValue(noticeHandler, forKey: BtcFacadeResultKeys.noticeHandler.rawValue)
            let waitOperation = createWaitingOperation(withdrawalQueue)
            let noticeHandleOperation = createNoticeHandleOperation(withdrawalQueue,
                                                                    BtcFacadeResultKeys.noticeHandler.rawValue,
                                                                    BtcFacadeResultKeys.notice.rawValue,
                                                                    BtcFacadeResultKeys.noticeError.rawValue)
            withdrawalQueue.addOperation(waitOperation)
            withdrawalQueue.addOperation(noticeHandleOperation)
        }
        
        withdrawalQueue.addOperation(completionOperation)
    }
    // swiftlint:enable function_body_length
    
    fileprivate func createBildGenerationOperation(_ queue: ECHOQueue,
                                                   _ backupAddress: String,
                                                   _ asset: Asset,
                                                   _ completion: @escaping Completion<Bool>) -> Operation {
        
        let bildTransferOperation = BlockOperation()
        
        bildTransferOperation.addExecutionBlock { [weak bildTransferOperation, weak queue] in
            
            guard bildTransferOperation?.isCancelled == false else { return }
            
            guard let account: Account = queue?.getValue(BtcFacadeResultKeys.loadedAccount.rawValue) else { return }
            
            let fee = AssetAmount(amount: 0, asset: asset)
            
            let extractedExpr = SidechainBTCCreateAddressOperation(account: account,
                                                                   backupAddress: backupAddress,
                                                                   fee: fee)
            let transferOperation = extractedExpr
            
            queue?.saveValue(transferOperation, forKey: BtcFacadeResultKeys.operation.rawValue)
        }
        
        return bildTransferOperation
    }
    
    fileprivate func createBildWithdrawalOperation(_ queue: ECHOQueue,
                                                   _ asset: Asset,
                                                   _ amount: UInt,
                                                   _ toBtcAddress: String,
                                                   _ completion: @escaping Completion<Bool>) -> Operation {
        
        let bildWithdrawalOperation = BlockOperation()
        
        bildWithdrawalOperation.addExecutionBlock { [weak bildWithdrawalOperation, weak queue] in
            
            guard bildWithdrawalOperation?.isCancelled == false else { return }
            
            guard let account: Account = queue?.getValue(BtcFacadeResultKeys.loadedAccount.rawValue) else { return }
            
            let fee = AssetAmount(amount: 0, asset: asset)
            
            let withdrawalOperation = SidechainBTCWithdrawOperation(account: account,
                                                                    value: amount,
                                                                    btcAddress: toBtcAddress,
                                                                    fee: fee)
            
            queue?.saveValue(withdrawalOperation, forKey: BtcFacadeResultKeys.operation.rawValue)
        }
        
        return bildWithdrawalOperation
    }
    
    fileprivate func createNoticeHandleOperation(_ queue: ECHOQueue,
                                                 _ noticeHandlerKey: String,
                                                 _ noticeKey: String,
                                                 _ noticeErrorKey: String) -> Operation {
        
        let noticeOperation = BlockOperation()
        
        noticeOperation.addExecutionBlock { [weak noticeOperation, weak queue, weak self] in
            
            guard noticeOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let noticeHandler: NoticeHandler = queue?.getValue(noticeHandlerKey) else { return }
            
            if let notice: ECHONotification = queue?.getValue(noticeKey) {
                let result = Result<ECHONotification, ECHOError>(value: notice)
                noticeHandler(result)
                return
            }
            
            if let noticeError: ECHOError = queue?.getValue(noticeErrorKey) {
                let result = Result<ECHONotification, ECHOError>(error: noticeError)
                noticeHandler(result)
                return
            }
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

extension BtcFacadeImp: NoticeEventDelegate {
    
    public func didReceiveNotification(notification: ECHONotification) {
        
        switch notification.params {
        case .array(let array):
            if let noticeOperationId = array.first as? Int {
                
                for queue in queues.values {
                    
                    if let queueTransferOperationId: Int = queue.getValue(BtcFacadeResultKeys.operationId.rawValue),
                        queueTransferOperationId == noticeOperationId {
                        queue.saveValue(notification, forKey: BtcFacadeResultKeys.notice.rawValue)
                        queue.startNextOperation()
                    }
                }
            }
        default:
            break
        }
    }
    
    public func didAllNoticesLost() {
        for queue in queues.values {
            queue.saveValue(ECHOError.connectionLost, forKey: BtcFacadeResultKeys.noticeError.rawValue)
            queue.startNextOperation()
        }
    }
}
