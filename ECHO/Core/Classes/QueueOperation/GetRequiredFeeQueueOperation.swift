//
//  GetRequiredFeeQueueOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 06.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

typealias GetRequiredFeeQueueOperationInitParams = (queue: ECHOQueue,
                                                    databaseService: DatabaseApiService,
                                                    asset: Asset,
                                                    operationKey: String,
                                                    saveKey: String,
                                                    feeMultiplier: UInt)

/**
    Operation for [ECHOQueue](ECHOQueue) whitch load and save required fee for [Operation](Operation)
 
    - Save [AssetAmount](AssetAmount)
 */
final class GetRequiredFeeQueueOperation<T>: Operation where T: Any {
    
    fileprivate weak var queue: ECHOQueue?
    fileprivate weak var databaseService: DatabaseApiService?
    fileprivate let asset: Asset
    fileprivate let operationKey: String
    fileprivate let saveKey: String
    fileprivate let feeMultiplier: UInt
    fileprivate let completion: Completion<T>
    
    required init(initParams: GetRequiredFeeQueueOperationInitParams,
                  completion: @escaping Completion<T>) {
        
        self.queue = initParams.queue
        self.databaseService = initParams.databaseService
        self.asset = initParams.asset
        self.operationKey = initParams.operationKey
        self.saveKey = initParams.saveKey
        self.feeMultiplier = initParams.feeMultiplier
        self.completion = completion
    }
    
    override func main() {
        super.main()
        
        if isCancelled { return }
        guard let operation: BaseOperation = queue?.getValue(operationKey) else { return }
        
        databaseService?.getRequiredFees(operations: [operation],
                                         asset: asset,
                                         completion: { [weak self] (result) in
                                            
            switch result {
            case .success(let fees):
                guard let fee = fees.first else {
                    self?.queue?.cancelAllOperations()
                    let result = Result<T, ECHOError>(error: ECHOError.resultNotFound)
                    self?.completion(result)
                    break
                }
                
                if let strongSelf = self {
                    
                    let multipliedFee = AssetAmount(amount: fee.amount * strongSelf.feeMultiplier,
                                                    asset: fee.asset)
                    
                    strongSelf.queue?.saveValue(multipliedFee, forKey: strongSelf.saveKey)
                }
            case .failure(let error):
                self?.queue?.cancelAllOperations()
                let result = Result<T, ECHOError>(error: error)
                self?.completion(result)
            }
            
            self?.queue?.startNextOperation()
        })
        
        queue?.waitStartNextOperation()
    }
}
