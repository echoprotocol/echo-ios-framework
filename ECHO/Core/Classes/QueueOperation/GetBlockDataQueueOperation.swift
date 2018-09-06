//
//  GetBlockDataQueueOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 06.09.2018.
//

typealias GetBlockDataQueueOperationInitParams = (queue: ECHOQueue, databaseService: DatabaseApiService, saveKey: String)

final class GetBlockDataQueueOperation<T>: Operation where T: Any {
    
    fileprivate weak var queue: ECHOQueue?
    fileprivate weak var databaseService: DatabaseApiService?
    fileprivate let saveKey: String
    fileprivate let completion: Completion<T>
    
    required init(initParams: GetBlockDataQueueOperationInitParams, completion: @escaping Completion<T>) {
        
        self.queue = initParams.queue
        self.databaseService = initParams.databaseService
        self.saveKey = initParams.saveKey
        self.completion = completion
    }
    
    override func main() {
        super.main()
        
        if isCancelled { return }
        
        databaseService?.getBlockData(completion: { [weak self] (result) in
            switch result {
            case .success(let blockData):
                if let strongSelf = self {
                    strongSelf.queue?.saveValue(blockData, forKey: strongSelf.saveKey)
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
