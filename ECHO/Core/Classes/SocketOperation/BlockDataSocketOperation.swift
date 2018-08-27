//
//  BlockDataSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct BlockDataSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var completion: Completion<BlockData>
    
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
                let result = Result<BlockData, ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .dictionary(let dict):
                    let data = try JSONSerialization.data(withJSONObject: dict, options: [])
                    let blockData = try JSONDecoder().decode(BlockData.self, from: data)
                    let result = Result<BlockData, ECHOError>(value: blockData)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<BlockData, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
}
