//
//  GetBlockSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct GetBlockSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var blockNumber: Int
    var completion: Completion<Block>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.block.rawValue,
                            [blockNumber]]
        return array
    }
    
    func complete(json: [String: Any]) {
        
        let result = (json["result"] as? [String: Any])
            .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: []) }
            .flatMap { try? JSONDecoder().decode(Block.self, from: $0) }
            .flatMap { Result<Block, ECHOError>(value: $0) }
        
        if let result = result {
            completion(result)
        } else {
            let result = Result<Block, ECHOError>(error: ECHOError.undefined)
            completion(result)
        }
    }
}
