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
    var needClearFilter: Bool
    var completion: Completion<Bool>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.subscribeCallback.rawValue,
                            [operationId, needClearFilter]]
        return array
    }
    
    func complete(json: [String: Any]) {
        
        let result = json["result"]
        
        if let _ = result {
            let result = Result<Bool, ECHOError>(value: true)
            completion(result)
        } else {
            let result = Result<Bool, ECHOError>(value: false)
            completion(result)
        }
    }
}
