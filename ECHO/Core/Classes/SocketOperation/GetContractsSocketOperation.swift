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
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            
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
    
    func forceEnd(error: ECHOError) {
        let result = Result<[ContractInfo], ECHOError>(error: error)
        completion(result)
    }
}
