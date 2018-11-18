//
//  GetAssetsSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Get a list of assets by id.
 
    - Return: [[Asset](Asset)]
 */
struct GetAssetsSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var assestsIds: [String]
    var completion: Completion<[Asset]>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.assets.rawValue,
                            [assestsIds]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {            
            switch response.response {
            case .error(let error):
                let result = Result<[Asset], ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let array):
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let assets = try JSONDecoder().decode([Asset].self, from: data)
                    let result = Result<[Asset], ECHOError>(value: assets)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[Asset], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<[Asset], ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
