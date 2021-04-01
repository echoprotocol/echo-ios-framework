//
//  GetKeyReferencesSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 22/02/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Find all account for every key in account role.
 
    - Return: [[String]] - array of arrays with account id for one key
 */
struct GetKeyReferencesSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var keys: [String]
    var completion: Completion<[[String]]>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.getKeyReferences.rawValue,
                            [keys]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            
            switch response.response {
            case .error(let error):
                let result = Result<[[String]], ECHOError>(error: ECHOError.internalError(error))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let array):
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let accountIds = try JSONDecoder().decode([[String]].self, from: data)
                    let result = Result<[[String]], ECHOError>(value: accountIds)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[[String]], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<[[String]], ECHOError>(error: error)
        completion(result)
    }
}
