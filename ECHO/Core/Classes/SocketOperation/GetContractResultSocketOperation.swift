//
//  GetContractResultSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Retrieves result of called contract operation
 
    - Return: [ContractResultEVM](ContractResultEVM)
 */
struct GetContractResultSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var contractResultId: String
    var completion: Completion<ContractResultEnum>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.contractResult.rawValue,
                            [contractResultId]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            
            switch response.response {
            case .error(let error):
                let result = Result<ContractResultEnum, ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let arr):
                    let data = try JSONSerialization.data(withJSONObject: arr, options: [])
                    let contractResult = try JSONDecoder().decode(ContractResultEnum.self, from: data)
                    let result = Result<ContractResultEnum, ECHOError>(value: contractResult)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<ContractResultEnum, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<ContractResultEnum, ECHOError>(error: error)
        completion(result)
    }
}
