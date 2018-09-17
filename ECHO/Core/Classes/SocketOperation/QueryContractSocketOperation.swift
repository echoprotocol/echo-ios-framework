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
    var assetId: String
    var code: String
    var completion: Completion<String>
    
    func createParameters() -> [Any] {
        
        let array: [Any] = [apiId,
                            SocketOperationKeys.callContractNoChangingState.rawValue,
                            [contractId, registrarId, assetId, code]]
        return array
    }
    
    func complete(json: [String: Any]) {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let response = try JSONDecoder().decode(ECHOResponse.self, from: data)
            
            switch response.response {
            case .error(let error):
                let result = Result<String, ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .string(let string):
                    completion(Result<String, ECHOError>(value: string))
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<String, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
}
