//
//  SetSubscribeCallbackSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct SetSubscribeCallbackSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var completion: Completion<Any>
    var needClearFilter: Bool
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.subscribeCallback.rawValue,
                            [operationId, [needClearFilter]]]
        return array
    }
    
    func complete(json: [String: Any]) {
        
    }
}
