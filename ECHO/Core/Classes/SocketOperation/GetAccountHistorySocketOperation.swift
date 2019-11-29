//
//  GetAccountHistorySocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Get operations relevant to the specified account.
 
    - Return: [[HistoryItem](HistoryItem)]
 */
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
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            
            switch response.response {
            case .error(let error):
                let result = Result<[HistoryItem], ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let array):
                    
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let history = try JSONDecoder().decode([HistoryItem].self, from: data)
                    let result = Result<[HistoryItem], ECHOError>(value: history)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[HistoryItem], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<[HistoryItem], ECHOError>(error: error)
        completion(result)
    }
}
