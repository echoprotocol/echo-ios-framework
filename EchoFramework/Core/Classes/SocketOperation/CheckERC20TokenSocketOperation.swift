//
//  CheckERC20TokenSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 29.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Return true if the contract exists and is ERC20 token contract registered by register_erc20_contract operation.
 
    - Return: [Bool](Bool)
 */
struct CheckERC20TokenSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var contractId: String
    var completion: Completion<Bool>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.checkERC20Token.rawValue,
                            [contractId]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        do {
            switch response.response {
            case .error(let error):
                let result = Result<Bool, ECHOError>(error: ECHOError.internalError(error))
                completion(result)
            case .result(let result):
                
                switch result {
                case .integer(let integer):
                    let result = Result<Bool, ECHOError>(value: integer > 0)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<Bool, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<Bool, ECHOError>(error: error)
        completion(result)
    }
}
