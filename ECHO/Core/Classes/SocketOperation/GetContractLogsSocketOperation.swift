//
//  GetContractLogsSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 19/11/2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Retrieves contract logs from block to block of called contract
 
    - Return: [ContractLogEnum](ContractLogEnum)
 */
struct GetContractLogsSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var contractId: String
    var fromBlock: Int
    var toBlock: Int
    var completion: Completion<[ContractLogEnum]>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.getContractLogs.rawValue,
                            [
                                [
                                    "contracts": [contractId],
                                    "from_block": fromBlock,
                                    "to_block": toBlock
                                ]
                            ]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            
            switch response.response {
            case .error(let error):
                let result = Result<[ContractLogEnum], ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let array):
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let logs = try JSONDecoder().decode([ContractLogEnum].self, from: data)
                    let result = Result<[ContractLogEnum], ECHOError>(value: logs)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[ContractLogEnum], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<[ContractLogEnum], ECHOError>(error: error)
        completion(result)
    }
}
