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
final public class TransactionFacadeImp: TransactionFacade, ECHOQueueble, NoticeEventDelegate {
    
    public var queues: [String: ECHOQueue]
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
    }
    
    // swiftlint:disable function_body_length
    public func sendTransferOperation(fromNameOrId: String,
                                      wif: String,
                                      toNameOrId: String,
                                      amount: UInt,
                                      asset: String,
                                      assetForFee: String?,
                                      sendCompletion: @escaping Completion<Void>,
                                      confirmNoticeHandler: NoticeHandler?) {
        
        // if we don't hace assetForFee, we use asset.
        let assetForFee = assetForFee ?? asset
        
        // Validate asset id
        do {
            let validator = IdentifierValidator()
            try validator.validateId(asset, for: .asset)
            try validator.validateId(assetForFee, for: .asset)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<Void, ECHOError>(error: echoError)
            sendCompletion(result)
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
        let getAccountsOperation = GetAccountsQueueOperation<Void>(initParams: getAccountsOperationInitParams,
                                                                          completion: sendCompletion)
        
        let bildTransferOperation = createBildTransferOperation(transferQueue, amount, asset, sendCompletion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (transferQueue,
                                                 services.databaseService,
                                                 Asset(assetForFee),
                                                 TransferResultsKeys.operation.rawValue,
                                                 TransferResultsKeys.fee.rawValue,
                                                 UInt(1))
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<Void>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: sendCompletion)
        
        // ChainId
        let getChainIdInitParams = (transferQueue, services.databaseService, TransferResultsKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<Void>(initParams: getChainIdInitParams,
                                                                 completion: sendCompletion)
    
        // BlockData
        let getBlockDataInitParams = (transferQueue, services.databaseService, TransferResultsKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<Void>(initParams: getBlockDataInitParams,
                                                                     completion: sendCompletion)
        
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
        let bildTransactionOperation = GetTransactionQueueOperation<Void>(initParams: transactionOperationInitParams,
                                                                          completion: sendCompletion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (transferQueue,
                                                 services.networkBroadcastService,
                                                 EchoQueueMainKeys.operationId.rawValue,
                                                 TransferResultsKeys.transaction.rawValue)
        let sendTransactionOperation = SendTransactionQueueOperation(initParams: sendTransacionOperationInitParams,
                                                                     completion: sendCompletion)
        
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
        if let noticeHandler = confirmNoticeHandler {
            transferQueue.saveValue(noticeHandler, forKey: EchoQueueMainKeys.noticeHandler.rawValue)
            
            let waitingOperationParams = (
                transferQueue,
                EchoQueueMainKeys.notice.rawValue,
                EchoQueueMainKeys.noticeError.rawValue
            )
            let waitOperation = WaitQueueOperation(initParams: waitingOperationParams)
            
            let noticeHadleOperaitonParams = (
                transferQueue,
                EchoQueueMainKeys.notice.rawValue,
                EchoQueueMainKeys.noticeError.rawValue,
                EchoQueueMainKeys.noticeHandler.rawValue
            )
            let noticeHandleOperation = NoticeHandleQueueOperation(initParams: noticeHadleOperaitonParams)
            
            transferQueue.addOperation(waitOperation)
            transferQueue.addOperation(noticeHandleOperation)
        }
        
        transferQueue.addOperation(completionOperation)
    }
    // swiftlint:enable function_body_length
    
    fileprivate func createBildTransferOperation(_ queue: ECHOQueue,
                                                 _ amount: UInt,
                                                 _ asset: String,
                                                 _ completion: @escaping Completion<Void>) -> Operation {
        
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
}
