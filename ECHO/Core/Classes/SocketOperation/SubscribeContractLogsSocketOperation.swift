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
 
    - Return: [ContractLogEnum](ContractLogEnum)
 */
struct SubscribeContractLogsSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var contractId: String
    var completion: Completion<Bool>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.subscribeContractLogs.rawValue,
                            [operationId, contractId]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
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
                let result = Result<Bool, ECHOError>(error: ECHOError.encodableMapping)
                completion(result)
            }
        }
    }
    
    func forceEnd() {
        let result = Result<Bool, ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
