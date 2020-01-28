//
//  GetContractLogsSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 19/11/2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Retrieves contract logs from block to block of called contract. The logs will receive from notice by operation Id
 
    - Return: Bool(Bool)
 */
struct GetContractLogsSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var contractId: String
    var fromBlock: Int
    var toBlock: Int
    var completion: Completion<Bool>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.getContractLogs.rawValue,
                            [
                                operationId,
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
                let result = Result<Bool, ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .undefined:
                    let result = Result<Bool, ECHOError>(value: true)
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
