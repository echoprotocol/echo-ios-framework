//
//  GetAccountWithdrawalsSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 11/06/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

/**
    Returns all approved withdrawals, for the given account id
 
    - Return: [[WithdrawalEth]](WithdrawalEth)
 */
struct GetAccountWithdrawalsSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var accountId: String
    var completion: Completion<[WithdrawalEth]>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.getAccountWithdrawals.rawValue,
                            [accountId]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            
            switch response.response {
            case .error(let error):
                let result = Result<[WithdrawalEth], ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let array):
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let accountIds = try JSONDecoder().decode([WithdrawalEth].self, from: data)
                    let result = Result<[WithdrawalEth], ECHOError>(value: accountIds)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[WithdrawalEth], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<[WithdrawalEth], ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
