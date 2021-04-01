//
//  GetBalanceObjectsSocketOperation.swift
//  ECHO
//
//  Created by Alexander Eskin on 10/1/20.
//  Copyright © 2020 PixelPlex. All rights reserved.
//

import Foundation

/**
   Return all unclaimed balance objects for a set of public keys.

   - Return: [[BalanceObject]](BalanceObject)
*/
struct GetBalanceObjectsSocketOperation: SocketOperation {
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var publicKeys: [String]
    var completion: Completion<[BalanceObject]>
    
    func createParameters() -> [Any] {
        let array: [Any] = [
            apiId,
            SocketOperationKeys.getBalanceObjects.rawValue,
            [publicKeys]
        ]
        
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        do {
            switch response.response {
            case .error(let error):
                let result = Result<[BalanceObject], ECHOError>(error: ECHOError.internalError(error))
                completion(result)
                
            case .result(let result):
                switch result {
                case .array(let array):
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let balances = try JSONDecoder().decode([BalanceObject].self, from: data)
                    let result = Result<[BalanceObject], ECHOError>(value: balances)
                    completion(result)
                    
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[BalanceObject], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<[BalanceObject], ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
