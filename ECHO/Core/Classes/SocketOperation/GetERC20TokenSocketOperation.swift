//
//  GetERC20TokenSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 31.10.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

/**
    Returns information about erc20 token, if then exist.
 
    - Return: [WithdrawalEth](WithdrawalEth)
 */
struct GetERC20TokenSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var ethAddress: String
    var completion: Completion<ERC20Token>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.getERC20Token.rawValue,
                            [ethAddress]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        do {
            switch response.response {
            case .error(let error):
                let result = Result<ERC20Token, ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let array):
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let token = try JSONDecoder().decode(ERC20Token.self, from: data)
                    let result = Result<ERC20Token, ECHOError>(value: token)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<ERC20Token, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<ERC20Token, ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
