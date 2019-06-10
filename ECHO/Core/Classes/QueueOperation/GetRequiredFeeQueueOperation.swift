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
                    
                    switch fee {
                    case .defaultFee(let asset):
                        let multipliedFee = AssetAmount(amount: asset.amount * strongSelf.feeMultiplier,
                                                        asset: asset.asset)
                        strongSelf.queue?.saveValue(FeeType.defaultFee(multipliedFee), forKey: strongSelf.saveKey)
                    case .callContractFee(let callContractFee):
                        let multipliedFee = AssetAmount(amount: callContractFee.fee.amount * strongSelf.feeMultiplier,
                                                        asset: callContractFee.fee.asset)
                        let multipliedUserToPay = AssetAmount(amount: callContractFee.userToPay.amount * strongSelf.feeMultiplier,
                                                              asset: callContractFee.userToPay.asset)
                        
                        let multipliedCallContractFee = CallContractFee(fee: multipliedFee,
                                                                        userToPay: multipliedUserToPay)
                        
                        strongSelf.queue?.saveValue(FeeType.callContractFee(multipliedCallContractFee),
                                                    forKey: strongSelf.saveKey)
                    }
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
