//
//  GetObjectsSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Get the objects corresponding to the provided IDs.
 
    - Return: [Any](Any)
 
    - Note: Not completed
 */
struct GetObjectsSocketOperation<T>: SocketOperation where T: Decodable {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var identifiers: [String]
    var completion: Completion<[T]>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.object.rawValue,
                            [identifiers]]
        return array
    }
    
    func complete(json: [String: Any]) {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let response = try JSONDecoder().decode(ECHOResponse.self, from: data)
            
            switch response.response {
            case .error(let error):
                let result = Result<[T], ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let array):
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let objects = try JSONDecoder().decode([T].self, from: data)
                    let result = Result<[T], ECHOError>(value: objects)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[T], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<[T], ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
