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
    var completion: Completion<Any>
    
    func createParameters() -> [Any] {
        
        let array: [Any] = [apiId,
                            SocketOperationKeys.blockData.rawValue,
                            []]
        return array
    }
    
    func complete(json: [String: Any]) {
        
    }
}
