//
//  SubscribeContractsSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 17/05/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
 Register subscription callback to contracts changes (history or object changes).
 Every notification initiated by the full node will carry a particular id as defined by the
 user with the identifier parameter.

 
 - Return: [Bool](Bool)
 */
struct SubscribeContractsSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var contractIds: [String]
    var completion: Completion<Bool>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.subscribeContracts.rawValue,
                            [contractIds]]
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
