//
//  GetIsReservedAccountQueueOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 4/22/19.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

typealias GetIsAccountReservedQueueOperationInitParams = (queue: ECHOQueue,
                                                          databaseService: DatabaseApiService,
                                                          namesOrId: String)

final class GetIsReservedAccountQueueOperation<T>: Operation where T: Any {
    
    fileprivate weak var queue: ECHOQueue?
    fileprivate weak var databaseService: DatabaseApiService?
    fileprivate let namesOrId: String
    fileprivate let completion: Completion<T>
    var defaultError: ECHOError = .resultNotFound
    
    required init(initParams: GetIsAccountReservedQueueOperationInitParams, completion: @escaping Completion<T>) {
        
        self.queue = initParams.queue
        self.databaseService = initParams.databaseService
        self.namesOrId = initParams.namesOrId
        self.completion = completion
    }
    
    override func main() {
        super.main()
        
        if isCancelled { return }
        
        databaseService?.getFullAccount(nameOrIds: [namesOrId], shoudSubscribe: false, completion: { [weak self] (result) in
            switch result {
            case .success(let accounts):
                
                if accounts.count > 0 {
                    guard let strongSelf = self else { break }
                    self?.queue?.cancelAllOperations()
                    let result = Result<T, ECHOError>(error: strongSelf.defaultError)
                    self?.completion(result)
                } else {
                    self?.queue?.startNextOperation()
                }
            case .failure:
                self?.queue?.startNextOperation()
            }
        })
        
        queue?.waitStartNextOperation()
    }
}
