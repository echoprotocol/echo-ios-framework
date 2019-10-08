//
//  SubscribeContractLogsSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 19/11/2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Register subscription callback to contract logs.
    Every notification initiated by the full node will carry a particular id as defined by the
    user with the identifier parameter.
 
    - Return: [ContractLog](ContractLog)
 */
struct SubscribeContractLogsSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var contractId: String
    var completion: Completion<[ContractLog]>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.subscribeContractLogs.rawValue,
                            [operationId, contractId, 0, 100]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            
            switch response.response {
            case .error(let error):
                let result = Result<[ContractLog], ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let array):
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let logs = try JSONDecoder().decode([ContractLog].self, from: data)
                    let result = Result<[ContractLog], ECHOError>(value: logs)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[ContractLog], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<[ContractLog], ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
