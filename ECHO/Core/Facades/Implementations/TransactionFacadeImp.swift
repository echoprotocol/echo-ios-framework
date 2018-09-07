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
    Implementation of [TransactionFacade](TransactionFacade)
 */
final public class TransactionFacadeImp: TransactionFacade, ECHOQueueble {
    
    var queues: [ECHOQueue]
    let services: TransactionFacadeServices
    let network: Network
    let cryptoCore: CryptoCoreComponent
    
    public init(services: TransactionFacadeServices, cryptoCore: CryptoCoreComponent, network: Network) {
        
        self.services = services
        self.network = network
        self.cryptoCore = cryptoCore
        self.queues = [ECHOQueue]()
    }
    
    private enum TransferResultsKeys: String {
        case loadedToAccount
        case loadedFromAccount
        case blockData
        case chainId
        case operation
        case fee
        case transaction
        case memo
    }
    
    public func sendTransferOperation(fromNameOrId: String,
                                      password: String,
                                      toNameOrId: String,
                                      amount: UInt,
                                      asset: String,
                                      message: String?,
                                      completion: @escaping Completion<Bool>) {
        
        let transferQueue = ECHOQueue()
        queues.append(transferQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(fromNameOrId, TransferResultsKeys.loadedFromAccount.rawValue),
                                                                          (toNameOrId, TransferResultsKeys.loadedToAccount.rawValue)])
        let getAccountsOperationInitParams = (transferQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<Bool>(initParams: getAccountsOperationInitParams,
                                                                          completion: completion)
        
        // Memo
        let getMemoOperationInitParams = (queue: transferQueue,
                                          cryptoCore: cryptoCore,
                                          message: message,
                                          saveKey: TransferResultsKeys.memo.rawValue,
                                          password: password,
                                          networkPrefix: network.prefix.rawValue,
                                          fromAccountKey: TransferResultsKeys.loadedFromAccount.rawValue,
                                          toAccountKey: TransferResultsKeys.loadedToAccount.rawValue)
        let getMemoOperation = GetMemoQueueOperation<Bool>(initParams: getMemoOperationInitParams,
                                                           completion: completion)
        
        let bildTransferOperation = createBildTransferOperation(transferQueue, password, message, amount, asset, completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (transferQueue,
                                                 services.databaseService,
                                                 Asset(asset),
                                                 TransferResultsKeys.operation.rawValue,
                                                 TransferResultsKeys.fee.rawValue)
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
                                              keychainType: KeychainType.active,
                                              saveKey: TransferResultsKeys.transaction.rawValue,
                                              password: password,
                                              networkPrefix: network.prefix.rawValue,
                                              fromAccountKey: TransferResultsKeys.loadedFromAccount.rawValue,
                                              operationKey: TransferResultsKeys.operation.rawValue,
                                              chainIdKey: TransferResultsKeys.chainId.rawValue,
                                              blockDataKey: TransferResultsKeys.blockData.rawValue,
                                              feeKey: TransferResultsKeys.fee.rawValue)
        let bildTransactionOperation = GetTransactionQueueOperation<Bool>(initParams: transactionOperationInitParams,
                                                                          completion: completion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (transferQueue,
                                                 services.networkBroadcastService,
                                                 TransferResultsKeys.transaction.rawValue)
        let sendTransactionOperation = SendTransactionQueueOperation(initParams: sendTransacionOperationInitParams,
                                                                     completion: completion)
        
        let completionOperation = createCompletionOperation(queue: transferQueue)
        
        transferQueue.addOperation(getAccountsOperation)
        transferQueue.addOperation(getMemoOperation)
        transferQueue.addOperation(bildTransferOperation)
        transferQueue.addOperation(getRequiredFeeOperation)
        transferQueue.addOperation(getChainIdOperation)
        transferQueue.addOperation(getBlockDataOperation)
        transferQueue.addOperation(bildTransactionOperation)
        transferQueue.addOperation(sendTransactionOperation)
        
        transferQueue.setCompletionOperation(completionOperation)
    }
    
    fileprivate func createBildTransferOperation(_ queue: ECHOQueue,
                                                 _ password: String,
                                                 _ message: String?,
                                                 _ amount: UInt,
                                                 _ asset: String,
                                                 _ completion: @escaping Completion<Bool>) -> Operation {
        
        let bildTransferOperation = BlockOperation()
        
        bildTransferOperation.addExecutionBlock { [weak bildTransferOperation, weak queue] in
            
            guard bildTransferOperation?.isCancelled == false else { return }
            
            guard let fromAccount: Account = queue?.getValue(TransferResultsKeys.loadedFromAccount.rawValue) else { return }
            guard let toAccount: Account = queue?.getValue(TransferResultsKeys.loadedToAccount.rawValue) else { return }
            guard let memo: Memo = queue?.getValue(TransferResultsKeys.memo.rawValue) else { return }
            
            let fee = AssetAmount(amount: 0, asset: Asset(asset))
            let amount = AssetAmount(amount: amount, asset: Asset(asset))
            let extractedExpr: TransferOperation = TransferOperation(from: fromAccount,
                                                                     to: toAccount,
                                                                     transferAmount: amount,
                                                                     fee: fee,
                                                                     memo: memo)
            let transferOperation = extractedExpr
            
            queue?.saveValue(transferOperation, forKey: TransferResultsKeys.operation.rawValue)
        }
        
        return bildTransferOperation
    }
}
