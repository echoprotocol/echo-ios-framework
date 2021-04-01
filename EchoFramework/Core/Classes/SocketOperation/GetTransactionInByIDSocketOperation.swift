//
//  GetTransactionInByIDSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 25.03.21.
//  Copyright © 2021 PixelPlex. All rights reserved.
//

/**
    Retrieve a transaction by transaction ID
 
    - Return: [Transaction](Transaction)
 */
struct GetTransactionInByIDSocketOperation: SocketOperation {
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var transactionID: String
    var completion: Completion<Transaction>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.getTransactionByID.rawValue,
                            [transactionID]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            
            switch response.response {
            case .error(let error):
                let result = Result<Transaction, ECHOError>(error: ECHOError.internalError(error))
                completion(result)
            case .result(let result):
                
                switch result {
                case .dictionary(let dict):
                    let data = try JSONSerialization.data(withJSONObject: dict, options: [])
                    let transaction = try JSONDecoder().decode(Transaction.self, from: data)
                    let result = Result<Transaction, ECHOError>(value: transaction)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<Transaction, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<Transaction, ECHOError>(error: error)
        completion(result)
    }
}
