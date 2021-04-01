//
//  GetChainIdQueueOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 06.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

typealias GetChainIdQueueOperationInitParams = (queue: ECHOQueue, databaseService: DatabaseApiService, saveKey: String)

/**
    Operation for [ECHOQueue](ECHOQueue) whitch load and save chain identifier
 
    - Save [String](String)
 */
final class GetChainIdQueueOperation<T>: Operation where T: Any {
    
    fileprivate weak var queue: ECHOQueue?
    fileprivate weak var databaseService: DatabaseApiService?
    fileprivate let saveKey: String
    fileprivate let completion: Completion<T>
    
    required init(initParams: GetChainIdQueueOperationInitParams, completion: @escaping Completion<T>) {

        self.queue = initParams.queue
        self.databaseService = initParams.databaseService
        self.saveKey = initParams.saveKey
        self.completion = completion
    }
    
    override func main() {
        super.main()
        
        if isCancelled { return }
        
        databaseService?.getChainId { [weak self] (result) in
            switch result {
            case .success(let chainId):
                if let strongSelf = self {
                    strongSelf.queue?.saveValue(chainId, forKey: strongSelf.saveKey)
                }
            case .failure(let error):
                self?.queue?.cancelAllOperations()
                let result = Result<T, ECHOError>(error: error)
                self?.completion(result)
            }
            
            self?.queue?.startNextOperation()
        }
        
        queue?.waitStartNextOperation()
    }
}
