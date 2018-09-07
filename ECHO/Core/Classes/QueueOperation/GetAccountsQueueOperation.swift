//
//  GetAccountsQueueOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 06.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

typealias GetAccountsNamesOrIdWithKeys = [(nameOrId: String, keyForSave: String)]
typealias GetAccountsQueueOperationInitParams = (queue: ECHOQueue,
                                                 databaseService: DatabaseApiService,
                                                 namesOrIdsWithKeys: GetAccountsNamesOrIdWithKeys)

/**
    Operation for [ECHOQueue](ECHOQueue) whitch load and save accounts
 
    - Save [Account](Account)
 */
final class GetAccountsQueueOperation<T>: Operation where T: Any {
    
    fileprivate weak var queue: ECHOQueue?
    fileprivate weak var databaseService: DatabaseApiService?
    fileprivate let namesOrIdsWithKeys: GetAccountsNamesOrIdWithKeys
    fileprivate let completion: Completion<T>
    
    required init(initParams: GetAccountsQueueOperationInitParams, completion: @escaping Completion<T>) {
        
        self.queue = initParams.queue
        self.databaseService = initParams.databaseService
        self.namesOrIdsWithKeys = initParams.namesOrIdsWithKeys
        self.completion = completion
    }
    
    override func main() {
        super.main()
        
        if isCancelled { return }
        
        var namesOrIds = [String]()
        namesOrIdsWithKeys.forEach {
            namesOrIds.append($0.nameOrId)
        }
        
        databaseService?.getFullAccount(nameOrIds: namesOrIds, shoudSubscribe: false, completion: { [weak self] (result) in
            switch result {
            case .success(let accounts):
                
                guard let strongSelf = self else { break }
                
                var wasNotFound = false
                strongSelf.namesOrIdsWithKeys.forEach {
                    guard let account = accounts[$0.nameOrId] else {
                        wasNotFound = true
                        return
                    }
                    strongSelf.queue?.saveValue(account.account, forKey: $0.keyForSave)
                }
                
                if wasNotFound {
                    self?.queue?.cancelAllOperations()
                    let result = Result<T, ECHOError>(error: ECHOError.resultNotFound)
                    self?.completion(result)
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
