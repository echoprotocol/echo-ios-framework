//
//  GetChainIdSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Get the chain id.
 
    - Return: [String](String)
 */
struct GetChainIdSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var completion: Completion<String>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.chainId.rawValue,
                            []]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        switch response.response {
        case .error(let error):
            let result = Result<String, ECHOError>(error: ECHOError.internalError(error.message))
            completion(result)
        case .result(let result):
            
            switch result {
            case .string(let string):
                let result = Result<String, ECHOError>(value: string)
                completion(result)
            default:
                let result = Result<String, ECHOError>(error: ECHOError.encodableMapping)
                completion(result)
            }
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<String, ECHOError>(error: error)
        completion(result)
    }
}
