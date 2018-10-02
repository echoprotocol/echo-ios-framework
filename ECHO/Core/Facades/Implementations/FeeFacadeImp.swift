//
//  FeeFacadeImp.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 27.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Services for FeeFacade
 */
public struct FeeFacadeServices {
    var databaseService: DatabaseApiService
}

/**
    Implementation of [FeeFacade](FeeFacade), [ECHOQueueble](ECHOQueueble)
 */
final public class FeeFacadeImp: FeeFacade, ECHOQueueble {
    
    var queues: [ECHOQueue]
    let services: FeeFacadeServices
    let network: ECHONetwork
    let cryptoCore: CryptoCoreComponent
    
    init(services: FeeFacadeServices, cryptoCore: CryptoCoreComponent, network: ECHONetwork) {

        self.services = services
        self.network = network
        self.cryptoCore = cryptoCore
        self.queues = [ECHOQueue]()
    }
    
    private enum FeeResultsKeys: String {
        case loadedToAccount
        case loadedFromAccount
        case memo
        case operation
        case fee
    }
    
    public func getFeeForTransferOperation(fromNameOrId: String,
                                           toNameOrId: String,
                                           amount: UInt,
                                           asset: String,
                                           assetForFee: String?,
                                           message: String?,
                                           completion: @escaping Completion<AssetAmount>) {
        
        // if we don't hace assetForFee, we use asset.
        let assetForFee = assetForFee ?? asset
        
        // Validate asset id
        do {
            let validator = IdentifierValidator()
            try validator.validateId(asset, for: .asset)
            try validator.validateId(assetForFee, for: .asset)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<AssetAmount, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        let feeQueue = ECHOQueue()
        queues.append(feeQueue)
        
        // Account
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(fromNameOrId, FeeResultsKeys.loadedFromAccount.rawValue),
                                                                          (toNameOrId, FeeResultsKeys.loadedToAccount.rawValue)])
        let getAccountsOperationInitParams = (feeQueue,
                                             services.databaseService,
                                             getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<AssetAmount>(initParams: getAccountsOperationInitParams,
                                                                  completion: completion)
        
        // Memo
        let getMemoOperationInitParams = (queue: feeQueue,
                                          cryptoCore: cryptoCore,
                                          message: message,
                                          saveKey: FeeResultsKeys.memo.rawValue,
                                          password: UUID().uuidString,
                                          networkPrefix: network.prefix.rawValue,
                                          fromAccountKey: FeeResultsKeys.loadedFromAccount.rawValue,
                                          toAccountKey: FeeResultsKeys.loadedToAccount.rawValue)
        let getMemoOperation = GetMemoQueueOperation<AssetAmount>(initParams: getMemoOperationInitParams,
                                                           completion: completion)
        
        // Operation
        let bildTransferOperation = createBildTransferOperation(feeQueue, amount, asset, completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (feeQueue,
                                                 services.databaseService,
                                                 Asset(assetForFee),
                                                 FeeResultsKeys.operation.rawValue,
                                                 FeeResultsKeys.fee.rawValue)
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<AssetAmount>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: completion)
        
        // FeeCompletion
        let feeCompletionOperation = createFeeComletionOperation(feeQueue, completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: feeQueue)
        
        feeQueue.addOperation(getAccountsOperation)
        feeQueue.addOperation(getMemoOperation)
        feeQueue.addOperation(bildTransferOperation)
        feeQueue.addOperation(getRequiredFeeOperation)
        feeQueue.addOperation(feeCompletionOperation)
        
        feeQueue.setCompletionOperation(completionOperation)
    }
    
    fileprivate func createBildTransferOperation(_ queue: ECHOQueue,
                                                 _ amount: UInt,
                                                 _ asset: String,
                                                 _ completion: @escaping Completion<AssetAmount>) -> Operation {
        
        let bildTransferOperation = BlockOperation()
        
        bildTransferOperation.addExecutionBlock { [weak bildTransferOperation, weak queue] in
            
            guard bildTransferOperation?.isCancelled == false else { return }
            
            guard let fromAccount: Account = queue?.getValue(FeeResultsKeys.loadedFromAccount.rawValue) else { return }
            guard let toAccount: Account = queue?.getValue(FeeResultsKeys.loadedFromAccount.rawValue) else { return }
            guard let memo: Memo = queue?.getValue(FeeResultsKeys.memo.rawValue) else { return }
            
            let fee = AssetAmount(amount: 0, asset: Asset(asset))
            let amount = AssetAmount(amount: amount, asset: Asset(asset))
            let transferOperation = TransferOperation(fromAccount: fromAccount,
                                                      toAccount: toAccount,
                                                      transferAmount: amount,
                                                      fee: fee,
                                                      memo: memo)
            
            queue?.saveValue(transferOperation, forKey: FeeResultsKeys.operation.rawValue)
        }
        
        return bildTransferOperation
    }
    
    fileprivate func createFeeComletionOperation(_ queue: ECHOQueue, _ completion: @escaping Completion<AssetAmount>) -> Operation {
        
        let feeCompletionOperation = BlockOperation()
        
        feeCompletionOperation.addExecutionBlock { [weak feeCompletionOperation, weak queue] in
            
            guard feeCompletionOperation?.isCancelled == false else { return }
            guard let fee: AssetAmount = queue?.getValue(FeeResultsKeys.fee.rawValue) else { return }
            
            let result = Result<AssetAmount, ECHOError>(value: fee)
            completion(result)
        }
        
        return feeCompletionOperation
    }
}
