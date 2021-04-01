//
//  GetGlobalPropertiesSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 26/02/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Retrieve the current global property object.
 
    - Return: [GlobalProperties](GlobalProperties)
 */
struct GetGlobalPropertiesSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var completion: Completion<GlobalProperties>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.getGlobalProperties.rawValue,
                            []]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            
            switch response.response {
            case .error(let error):
                let result = Result<GlobalProperties, ECHOError>(error: ECHOError.internalError(error))
                completion(result)
            case .result(let result):
                
                switch result {
                case .dictionary(let dict):
                    let data = try JSONSerialization.data(withJSONObject: dict, options: [])
                    let properties = try JSONDecoder().decode(GlobalProperties.self, from: data)
                    let result = Result<GlobalProperties, ECHOError>(value: properties)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<GlobalProperties, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<GlobalProperties, ECHOError>(error: error)
        completion(result)
    }
}
