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
    var completion: Completion<[HistoryItem]>
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
         completion: @escaping Completion<[HistoryItem]>) {
        
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
        
        let result = (json["result"] as? [[String: Any]])
            .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: []) }
            .flatMap { try? JSONDecoder().decode([HistoryItem].self, from: $0) }
            .flatMap { Result<[HistoryItem], ECHOError>(value: $0) }
        
        if let result = result {
            completion(result)
        } else {
            let result = Result<[HistoryItem], ECHOError>(error: ECHOError.undefined)
            completion(result)
        }
    }
}
