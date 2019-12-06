//
//  GetERC20AccountWithdrawalsSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 29.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Returns all ERC20 withdrawals, for the given account id.
 
    - Return: [[ERC20Withdrawal]](ERC20Withdrawal)
 */
struct GetERC20AccountWithdrawalsSocketOperation: SocketOperation {
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var accountId: String
    var completion: Completion<[ERC20Withdrawal]>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.getERC20AccountWithdrawals.rawValue,
                            [accountId]]
        
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            switch response.response {
            case .error(let error):
                let result = Result<[ERC20Withdrawal], ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                switch result {
                case .array(let array):
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let deposits = try JSONDecoder().decode([ERC20Withdrawal].self, from: data)
                    let result = Result<[ERC20Withdrawal], ECHOError>(value: deposits)
                    completion(result)
                    
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[ERC20Withdrawal], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<[ERC20Withdrawal], ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
