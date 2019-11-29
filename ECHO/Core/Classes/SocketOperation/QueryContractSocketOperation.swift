//
//  QueryContractSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 12.09.2018.
//

/**
    Calls contract operation without chaining blockchain state. Retrieves constant information.
 
    - Return: [String](String)
 */
struct QueryContractSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var contractId: String
    var registrarId: String
    var amount: UInt
    var assetId: String
    var code: String
    var completion: Completion<String>
    
    func createParameters() -> [Any] {
        
        let array: [Any] = [apiId,
                            SocketOperationKeys.callContractNoChangingState.rawValue,
                            [
                                contractId,
                                registrarId,
                                [
                                    "amount": amount,
                                    "asset_id": assetId
                                ],
                                code
                            ]]
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
