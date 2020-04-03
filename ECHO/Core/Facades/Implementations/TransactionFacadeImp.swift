//
//  TransactionFacadeImp.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 28.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Services for TransactionFacade
 */
public struct TransactionFacadeServices {
    var databaseService: DatabaseApiService
    var networkBroadcastService: NetworkBroadcastApiService
}

/**
    Implementation of [TransactionFacade](TransactionFacade), [ECHOQueueble](ECHOQueueble)
 */
final public class TransactionFacadeImp: TransactionFacade, ECHOQueueble {
    
    var queues: [String: ECHOQueue]
    let services: TransactionFacadeServices
    let network: ECHONetwork
    let cryptoCore: CryptoCoreComponent
    let transactionExpirationOffset: TimeInterval
    
    public init(services: TransactionFacadeServices,
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
    
    private enum TransferResultsKeys: String {
        case loadedToAccount
        case loadedFromAccount
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
    public func sendTransferOperation(fromNameOrId: String,
                                      wif: String,
                                      toNameOrId: String,
                                      amount: UInt,
                                      asset: String,
                                      assetForFee: String?,
                                      completion: @escaping Completion<Bool>,
                                      noticeHandler: NoticeHandler?) {
        
        // if we don't hace assetForFee, we use asset.
        let assetForFee = assetForFee ?? asset
        
        // Validate asset id
        do {
            let validator = IdentifierValidator()
            try validator.validateId(asset, for: .asset)
            try validator.validateId(assetForFee, for: .asset)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<Bool, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        let transferQueue = ECHOQueue()
        addQueue(transferQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(fromNameOrId, TransferResultsKeys.loadedFromAccount.rawValue),
                                                                          (toNameOrId, TransferResultsKeys.loadedToAccount.rawValue)])
        let getAccountsOperationInitParams = (transferQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<Bool>(initParams: getAccountsOperationInitParams,
                                                                          completion: completion)
        
        let bildTransferOperation = createBildTransferOperation(transferQueue, amount, asset, completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (transferQueue,
                                                 services.databaseService,
                                                 Asset(assetForFee),
                                                 TransferResultsKeys.operation.rawValue,
                                                 TransferResultsKeys.fee.rawValue,
                                                 UInt(1))
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<Bool>(initParams: getRequiredFeeOperationInitParams,
                                                                                completion: completion)
        
        // ChainId
        let getChainIdInitParams = (transferQueue, services.databaseService, TransferResultsKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<Bool>(initParams: getChainIdInitParams,
                                                                 completion: completion)
    
        // BlockData
        let getBlockDataInitParams = (transferQueue, services.databaseService, TransferResultsKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<Bool>(initParams: getBlockDataInitParams,
                                                                     completion: completion)
        
        // Transaciton
        let transactionOperationInitParams = (queue: transferQueue,
                                              cryptoCore: cryptoCore,
                                              saveKey: TransferResultsKeys.transaction.rawValue,
                                              wif: wif,
                                              networkPrefix: network.echorandPrefix.rawValue,
                                              fromAccountKey: TransferResultsKeys.loadedFromAccount.rawValue,
                                              operationKey: TransferResultsKeys.operation.rawValue,
                                              chainIdKey: TransferResultsKeys.chainId.rawValue,
                                              blockDataKey: TransferResultsKeys.blockData.rawValue,
                                              feeKey: TransferResultsKeys.fee.rawValue,
                                              expirationOffset: transactionExpirationOffset)
        let bildTransactionOperation = GetTransactionQueueOperation<Bool>(initParams: transactionOperationInitParams,
                                                                          completion: completion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (transferQueue,
                                                 services.networkBroadcastService,
                                                 TransferResultsKeys.operationId.rawValue,
                                                 TransferResultsKeys.transaction.rawValue)
        let sendTransactionOperation = SendTransactionQueueOperation(initParams: sendTransacionOperationInitParams,
                                                                     completion: completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: transferQueue)
        
        transferQueue.addOperation(getAccountsOperation)
        transferQueue.addOperation(bildTransferOperation)
        transferQueue.addOperation(getRequiredFeeOperation)
        transferQueue.addOperation(getChainIdOperation)
        transferQueue.addOperation(getBlockDataOperation)
        transferQueue.addOperation(bildTransactionOperation)
        transferQueue.addOperation(sendTransactionOperation)
        
        //Notice handler
        if let noticeHandler = noticeHandler {
            transferQueue.saveValue(noticeHandler, forKey: TransferResultsKeys.noticeHandler.rawValue)
            let waitOperation = createWaitingOperation(transferQueue)
            let noticeHandleOperation = createNoticeHandleOperation(transferQueue)
            transferQueue.addOperation(waitOperation)
            transferQueue.addOperation(noticeHandleOperation)
        }
        
        transferQueue.addOperation(completionOperation)
    }
    // swiftlint:enable function_body_length
    
    fileprivate func createBildTransferOperation(_ queue: ECHOQueue,
                                                 _ amount: UInt,
                                                 _ asset: String,
                                                 _ completion: @escaping Completion<Bool>) -> Operation {
        
        let bildTransferOperation = BlockOperation()
        
        bildTransferOperation.addExecutionBlock { [weak bildTransferOperation, weak queue] in
            
            guard bildTransferOperation?.isCancelled == false else { return }
            
            guard let fromAccount: Account = queue?.getValue(TransferResultsKeys.loadedFromAccount.rawValue) else { return }
            guard let toAccount: Account = queue?.getValue(TransferResultsKeys.loadedToAccount.rawValue) else { return }
            
            let fee = AssetAmount(amount: 0, asset: Asset(asset))
            let amount = AssetAmount(amount: amount, asset: Asset(asset))
            let extractedExpr: TransferOperation = TransferOperation(fromAccount: fromAccount,
                                                                     toAccount: toAccount,
                                                                     transferAmount: amount,
                                                                     fee: fee)
            let transferOperation = extractedExpr
            
            queue?.saveValue(transferOperation, forKey: TransferResultsKeys.operation.rawValue)
        }
        
        return bildTransferOperation
    }
    
    fileprivate func createNoticeHandleOperation(_ queue: ECHOQueue) -> Operation {
        
        let noticeOperation = BlockOperation()
        
        noticeOperation.addExecutionBlock { [weak noticeOperation, weak queue, weak self] in
            
            guard noticeOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let noticeHandler: NoticeHandler = queue?.getValue(TransferResultsKeys.noticeHandler.rawValue) else { return }
            
            if let notice: ECHONotification = queue?.getValue(TransferResultsKeys.notice.rawValue) {
                let result = Result<ECHONotification, ECHOError>(value: notice)
                noticeHandler(result)
                return
            }
            
            if let noticeError: ECHOError = queue?.getValue(TransferResultsKeys.noticeError.rawValue) {
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

extension TransactionFacadeImp: NoticeEventDelegate {
    
    public func didReceiveNotification(notification: ECHONotification) {
        
        switch notification.params {
        case .array(let array):
            if let noticeOperationId = array.first as? Int {
                
                for queue in queues.values {
                    
                    if let queueTransferOperationId: Int = queue.getValue(TransferResultsKeys.operationId.rawValue),
                        queueTransferOperationId == noticeOperationId {
                        queue.saveValue(notification, forKey: TransferResultsKeys.notice.rawValue)
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
            queue.saveValue(ECHOError.connectionLost, forKey: TransferResultsKeys.noticeError.rawValue)
            queue.startNextOperation()
        }
    }
}
