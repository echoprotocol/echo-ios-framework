//
//  TransactionSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 29.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Broadcast a transaction to the network.
    The [transaction] will be checked for validity in the local database prior to broadcasting. If it
    fails to apply locally, an error will be thrown and the transaction will not be broadcast.
 
    - Return: [Bool](Bool)
 */
struct TransactionSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var transaction: Transaction
    var completion: Completion<Bool>
    
    func createParameters() -> [Any] {
        
        let array: [Any] = [apiId,
                            SocketOperationKeys.transaction.rawValue,
                            [operationId, transaction.toJSON() ?? ""]]
        return array
    }
    
    func complete(json: [String: Any]) {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let response = try JSONDecoder().decode(ECHOResponse.self, from: data)
            
            switch response.response {
            case .error(let error):
                let result = Result<Bool, ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .undefined:
                    completion(Result<Bool, ECHOError>(value: true))
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<Bool, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
}
