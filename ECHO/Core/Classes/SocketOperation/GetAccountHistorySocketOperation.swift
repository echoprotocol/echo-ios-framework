//
//  GetAccountHistorySocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct GetAccountHistorySocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var completion: Completion<Any>
    var accountId: String
    var stopId: String
    var limit: Int
    var startId: String
    
    init(method: SocketOperationType,
         operationId: Int,
         apiId: Int,
         accountId: String,
         stopId: String = "1.11.0",
         limit: Int = 100,
         startId: String = "1.11.0",
         completion: @escaping Completion<Any>) {
        
        self.method = method
        self.operationId = operationId
        self.apiId = apiId
        self.accountId = accountId
        self.stopId = stopId
        self.startId = startId
        self.limit = limit
        self.completion = completion
    }
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.accountHistory.rawValue,
                            [accountId, stopId, limit, startId]]
        return array
    }
    
    func complete(json: [String: Any]) {
        
    }
}
