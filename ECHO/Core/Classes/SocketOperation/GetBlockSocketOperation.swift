//
//  GetBlockSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct GetBlockSocketOperation: SocketOperation {
    
    typealias Result = Bool
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var completion: Completion<Any>
    var blockNumber: Int
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.block.rawValue,
                            [blockNumber]]
        return array
    }
    
    func complete(json: [String: Any]) {
        
    }
}
