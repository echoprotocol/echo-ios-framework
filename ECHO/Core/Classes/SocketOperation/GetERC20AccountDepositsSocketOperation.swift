//
//  GetERC20AccountDepositsSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 29.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Returns all ERC20 deposits, for the given account id.
 
    - Return: [[ERC20Deposit]](ERC20Deposit)
 */
struct GetERC20AccountDepositsSocketOperation: SocketOperation {
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var accountId: String
    var completion: Completion<[ERC20Deposit]>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.getERC20AccountDeposits.rawValue,
                            [accountId]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            switch response.response {
            case .error(let error):
                let result = Result<[ERC20Deposit], ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                switch result {
                case .array(let array):
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let deposits = try JSONDecoder().decode([ERC20Deposit].self, from: data)
                    let result = Result<[ERC20Deposit], ECHOError>(value: deposits)
                    completion(result)
                    
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[ERC20Deposit], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<[ERC20Deposit], ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}

