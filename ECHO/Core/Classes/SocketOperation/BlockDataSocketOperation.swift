//
//  BlockDataSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Returns the block chain’s rapidly-changing properties. The returned object contains information
    that changes every block interval such as the head block number, the next witness, etc.
 
    - Return: [DynamicGlobalProperties]()
 */
struct BlockDataSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var completion: Completion<DynamicGlobalProperties>
    
    func createParameters() -> [Any] {
        
        let array: [Any] = [apiId,
                            SocketOperationKeys.blockData.rawValue,
                            []]
        return array
    }
    
    func complete(json: [String: Any]) {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let response = try JSONDecoder().decode(ECHOResponse.self, from: data)
            
            switch response.response {
            case .error(let error):
                let result = Result<DynamicGlobalProperties, ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .dictionary(let dict):
                    let data = try JSONSerialization.data(withJSONObject: dict, options: [])
                    let dynamicGlobalProperties = try JSONDecoder().decode(DynamicGlobalProperties.self, from: data)
                    let result = Result<DynamicGlobalProperties, ECHOError>(value: dynamicGlobalProperties)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<DynamicGlobalProperties, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<DynamicGlobalProperties, ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
