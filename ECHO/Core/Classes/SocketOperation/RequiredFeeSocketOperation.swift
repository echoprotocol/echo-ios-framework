//
//  RequiredFeeSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Represents blockchain call. Returns list of AssetAmount for operations
 
    - Return: [[AssetAmount](AssetAmount)]
 */
struct RequiredFeeSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var operations: [BaseOperation]
    var asset: Asset
    var completion: Completion<[AssetAmount]>
    
    func createParameters() -> [Any] {
        
        let assetId = asset.id
        var operations = [Any?]()
        
        for operation in self.operations {
            operations.append(operation.toJSON())
        }
        
        let array: [Any] = [apiId,
                            SocketOperationKeys.requiredFee.rawValue,
                            [operations, assetId]]
        return array
    }
    
    func complete(json: [String: Any]) {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let response = try JSONDecoder().decode(ECHOResponse.self, from: data)
            
            switch response.response {
            case .error(let error):
                let result = Result<[AssetAmount], ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let array):
                    
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let amounts = try JSONDecoder().decode([AssetAmount].self, from: data)
                    let result = Result<[AssetAmount], ECHOError>(value: amounts)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[AssetAmount], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<[AssetAmount], ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
