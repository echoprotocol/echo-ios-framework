//
//  GetFrozenBalances.swift
//  ECHO
//
//  Created by Alexander Eskin on 9/30/20.
//  Copyright © 2020 PixelPlex. All rights reserved.
//

import Foundation

/**
   Returns all frozen balances, for the given account id.

   - Return: [[FrozenBalanceObject]](FrozenBalanceObject)
*/

struct GetFrozenBalancesSocketOperation: SocketOperation {
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var accountID: String
    var completion: Completion<[FrozenBalanceObject]>
    
    func createParameters() -> [Any] {
        let array: [Any] = [
            apiId,
            SocketOperationKeys.getFrozenBalances.rawValue,
            [accountID]
        ]
        
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        do {
            switch response.response {
            case .error(let error):
                let result = Result<[FrozenBalanceObject], ECHOError>(error: ECHOError.internalError(error))
                completion(result)
                
            case .result(let result):
                switch result {
                case .array(let array):
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let balances = try JSONDecoder().decode([FrozenBalanceObject].self, from: data)
                    let result = Result<[FrozenBalanceObject], ECHOError>(value: balances)
                    completion(result)
                    
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[FrozenBalanceObject], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<[FrozenBalanceObject], ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
