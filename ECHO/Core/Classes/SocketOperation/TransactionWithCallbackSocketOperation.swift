//
//  TransactionWithCallbackSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11/17/18.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Broadcast a transaction with callback to the network.
    The [Transaction](Transaction) will be checked for validity in the local database prior to broadcasting. If it
    fails to apply locally, an error will be thrown and the transaction will not be broadcast.
 
    - Return: [Bool](Bool)
 */
struct TransactionWithCallbackSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var transaction: Transaction
    var completion: Completion<Void>
    
    func createParameters() -> [Any] {
        
        let array: [Any] = [apiId,
                            SocketOperationKeys.transactionWithCallBack.rawValue,
                            [operationId, transaction.toJSON() ?? ""]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        switch response.response {
        case .error(let error):
            let result = Result<Void, ECHOError>(error: ECHOError.internalError(error))
            completion(result)
        case .result(let result):
            
            switch result {
            case .undefined:
                let result = Result<Void, ECHOError>(value: ())
                completion(result)
            default:
                let result = Result<Void, ECHOError>(error: ECHOError.encodableMapping)
                completion(result)
            }
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<Void, ECHOError>(error: error)
        completion(result)
    }
}
