//
//  SendTransactionQueueOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 06.09.2018.
//

typealias SendTransactionQueueOperationInitParams = (queue: ECHOQueue,
                                                     networkBroadcastService: NetworkBroadcastApiService,
                                                     transactionKey: String)

final class SendTransactionQueueOperation: Operation {
    
    fileprivate weak var queue: ECHOQueue?
    fileprivate weak var networkBroadcastService: NetworkBroadcastApiService?
    fileprivate let transactionKey: String
    fileprivate let completion: Completion<Bool>
    
    required init(initParams: SendTransactionQueueOperationInitParams, completion: @escaping Completion<Bool>) {
        
        self.queue = initParams.queue
        self.networkBroadcastService = initParams.networkBroadcastService
        self.transactionKey = initParams.transactionKey
        self.completion = completion
    }
    
    override func main() {
        super.main()
        
        if isCancelled { return }
        
        guard let transction: Transaction = queue?.getValue(transactionKey) else { return }
        
        networkBroadcastService?.broadcastTransactionWithCallback(transaction: transction,
                                                                  completion: { [weak self] (result) in
            switch result {
            case .success(let success):
                let result = Result<Bool, ECHOError>(value: success)
                self?.completion(result)
            case .failure(let error):
                self?.queue?.cancelAllOperations()
                let result = Result<Bool, ECHOError>(error: error)
                self?.completion(result)
            }
            
            self?.queue?.startNextOperation()
        })
        
        queue?.waitStartNextOperation()
    }
}
