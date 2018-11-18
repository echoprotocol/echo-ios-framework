//
//  GetContractResultSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Retrieves result of called contract operation
 
    - Return: [ContractResult](ContractResult)
 */
struct GetContractResultSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var historyId: String
    var completion: Completion<ContractResult>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.contractResult.rawValue,
                            [historyId]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            
            switch response.response {
            case .error(let error):
                let result = Result<ContractResult, ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .dictionary(let dict):
                    let data = try JSONSerialization.data(withJSONObject: dict, options: [])
                    let contractResult = try JSONDecoder().decode(ContractResult.self, from: data)
                    let result = Result<ContractResult, ECHOError>(value: contractResult)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<ContractResult, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<ContractResult, ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
