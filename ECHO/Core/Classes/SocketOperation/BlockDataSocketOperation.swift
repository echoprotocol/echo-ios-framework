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
        
        let result = (json["result"] as? [String: Any])
            .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: []) }
            .flatMap { try? JSONDecoder().decode(BlockData.self, from: $0) }
            .flatMap { Result<BlockData, ECHOError>(value: $0) }
        
        if let result = result {
            completion(result)
        } else {
            let result = Result<BlockData, ECHOError>(error: ECHOError.undefined)
            completion(result)
        }
    }
}
