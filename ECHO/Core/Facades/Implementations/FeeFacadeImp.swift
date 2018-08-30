//
//  FeeFacadeImp.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 27.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct FeeFacadeServices {
    var databaseService: DatabaseApiService
}

class FeeFacadeImp: FeeFacade, ECHOQueueble {
    
    var queues: [ECHOQueue]
    var services: FeeFacadeServices
    
    required init(services: FeeFacadeServices) {

        self.services = services
        self.queues = [ECHOQueue]()
    }
    
    enum FeeResultsKeys: String {
        case loadedToAccount
        case loadedFromAccount
        case operation
        case fee
    }
    
    func getFeeForTransferOperation(fromNameOrId: String,
                                    toNameOrId: String,
                                    amount: UInt,
                                    asset: String,
                                    completion: @escaping Completion<AssetAmount>) {
        
        let feeQueue = ECHOQueue()
        queues.append(feeQueue)
        
        let getAccountsOperation = createGetAccountsOperation(feeQueue, fromNameOrId, toNameOrId, completion)
        let bildTransferOperation = createBildTransferOperation(feeQueue, amount, asset, completion)
        let getRequiredFee = createGetRequiredFeeOperation(feeQueue, asset, completion)
        let feeComletionOperation = createFeeComletionOperation(feeQueue, completion)
        let lastOperation = createLastOperation(queue: feeQueue)
        
        feeQueue.addOperation(getAccountsOperation)
        feeQueue.addOperation(bildTransferOperation)
        feeQueue.addOperation(getRequiredFee)
        feeQueue.addOperation(feeComletionOperation)
        feeQueue.addOperation(lastOperation)
    }
    
    func createGetAccountsOperation(_ queue: ECHOQueue,
                                    _ fromNameOrId: String,
                                    _ toNameOrId: String,
                                    _ completion: @escaping Completion<AssetAmount>) -> Operation {
        
        let getAccountsOperation = BlockOperation()
        
        getAccountsOperation.addExecutionBlock { [weak getAccountsOperation, weak queue, weak self] in
            
            guard getAccountsOperation?.isCancelled == false else { return }
            
            self?.services.databaseService.getFullAccount(nameOrIds: [fromNameOrId, toNameOrId], shoudSubscribe: false, completion: { (result) in
                switch result {
                case .success(let accounts):
                    
                    if let fromAccount = accounts[fromNameOrId], let toAccount = accounts[toNameOrId] {
                        queue?.saveValue(fromAccount.account, forKey: FeeResultsKeys.loadedFromAccount.rawValue)
                        queue?.saveValue(toAccount.account, forKey: FeeResultsKeys.loadedToAccount.rawValue)
                    } else {
                        queue?.cancelAllOperations()
                        let result = Result<AssetAmount, ECHOError>(error: ECHOError.resultNotFound)
                        completion(result)
                    }

                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<AssetAmount, ECHOError>(error: error)
                    completion(result)
                }
                
                queue?.startNextOperation()
            })
            
            queue?.waitStartNextOperation()
        }
        
        return getAccountsOperation
    }
    
    func createBildTransferOperation(_ queue: ECHOQueue,
                                     _ amount: UInt,
                                     _ asset: String,
                                     _ completion: @escaping Completion<AssetAmount>) -> Operation {
        
        let bildTransferOperation = BlockOperation()
        
        bildTransferOperation.addExecutionBlock { [weak bildTransferOperation, weak queue] in
            
            guard bildTransferOperation?.isCancelled == false else { return }
            
            guard let fromAccount: Account = queue?.getValue(FeeResultsKeys.loadedFromAccount.rawValue) else { return }
            guard let toAccount: Account = queue?.getValue(FeeResultsKeys.loadedFromAccount.rawValue) else { return }
            
            let fee = AssetAmount(amount: 0, asset: Asset(asset))
            let amount = AssetAmount(amount: amount, asset: Asset(asset))
            let transferOperation = TransferOperation(from: fromAccount,
                                                      to: toAccount,
                                                      transferAmount: amount,
                                                      fee: fee)
            
            queue?.saveValue(transferOperation, forKey: FeeResultsKeys.operation.rawValue)
        }
        
        return bildTransferOperation
    }
    
    func createGetRequiredFeeOperation(_ queue: ECHOQueue,
                                       _ asset: String,
                                       _ completion: @escaping Completion<AssetAmount>) -> Operation {
        
        let getRequiredFee = BlockOperation()
        
        getRequiredFee.addExecutionBlock { [weak getRequiredFee, weak queue, weak self] in
        
            guard getRequiredFee?.isCancelled == false else { return }
            guard let operation: TransferOperation = queue?.getValue(FeeResultsKeys.operation.rawValue) else { return }
            
            let asset = Asset(asset)
            
            self?.services.databaseService.getRequiredFees(operations: [operation], asset: asset, completion: { (result) in
                switch result {
                case .success(let fees):
                    if let fee = fees.first {
                        queue?.saveValue(fee, forKey: FeeResultsKeys.fee.rawValue)
                    }
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<AssetAmount, ECHOError>(error: error)
                    completion(result)
                }
                
                queue?.startNextOperation()
            })
            
            queue?.waitStartNextOperation()
        }
        
        return getRequiredFee
    }
    
    func createFeeComletionOperation(_ queue: ECHOQueue, _ completion: @escaping Completion<AssetAmount>) -> Operation {
        
        let feeComletionOperation = BlockOperation()
        
        feeComletionOperation.addExecutionBlock { [weak feeComletionOperation, weak queue] in
            
            guard feeComletionOperation?.isCancelled == false else { return }
            guard let fee: AssetAmount = queue?.getValue(FeeResultsKeys.fee.rawValue) else { return }
            
            let result = Result<AssetAmount, ECHOError>(value: fee)
            completion(result)
        }
        
        return feeComletionOperation
    }
}
