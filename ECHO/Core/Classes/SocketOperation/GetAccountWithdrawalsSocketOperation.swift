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
 
    - Return: [[EthWithdrawal]](EthWithdrawal)
 */
struct GetAccountWithdrawalsSocketOperation: SocketOperation {
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var accountId: String
    var type: SidechainType?
    var completion: Completion<[SidechainWithdrawalEnum]>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.getAccountWithdrawals.rawValue,
                            [accountId, type?.rawValue ?? String()]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            switch response.response {
            case .error(let error):
                let result = Result<[SidechainWithdrawalEnum], ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
                
            case .result(let result):
                switch result {
                case .array(let array):
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let withdrawals = try JSONDecoder().decode([SidechainWithdrawalEnum].self, from: data)
                    let result = Result<[SidechainWithdrawalEnum], ECHOError>(value: withdrawals)
                    completion(result)
                    
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[SidechainWithdrawalEnum], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<[SidechainWithdrawalEnum], ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
