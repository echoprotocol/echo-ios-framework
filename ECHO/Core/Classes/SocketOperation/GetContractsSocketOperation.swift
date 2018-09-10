//
//  GetContractsSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 10.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Retrieves information about selected contracts.
 
    - Return: [[ContractInfo](ContractInfo)]
 */
struct GetContractsSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var contractIds: [String]
    var completion: Completion<[ContractInfo]>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.getContracts.rawValue,
                            [contractIds]]
        return array
    }
    
    func complete(json: [String: Any]) {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let response = try JSONDecoder().decode(ECHOResponse.self, from: data)
            
            switch response.response {
            case .error(let error):
                let result = Result<[ContractInfo], ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let array):
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let contractsInfo = try JSONDecoder().decode([ContractInfo].self, from: data)
                    let result = Result<[ContractInfo], ECHOError>(value: contractsInfo)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[ContractInfo], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<[ContractInfo], ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
