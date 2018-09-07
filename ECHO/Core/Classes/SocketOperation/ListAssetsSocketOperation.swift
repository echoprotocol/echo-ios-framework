//
//  ListAssetsSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 04.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Get a list of assets by symbol
 
    - Return: [[Asset](Asset)]
 */
struct ListAssetsSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var lowerBound: String
    var limit: Int
    var completion: Completion<[Asset]>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.listAssets.rawValue,
                            [lowerBound, limit]]
        return array
    }
    
    func complete(json: [String: Any]) {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let response = try JSONDecoder().decode(ECHOResponse.self, from: data)
            
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
