//
//  SetSubscribeCallbackSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Register global subscription callback to object
    Every notification initiated by the full node will carry a particular id as defined by the
    user with the identifier parameter.
 
    - Return: [Bool](Bool)
 */
struct SetSubscribeCallbackSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var needClearFilter: Bool
    var completion: Completion<Void>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.subscribeCallback.rawValue,
                            [operationId, needClearFilter]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        switch response.response {
        case .error(let error):
            let result = Result<Void, ECHOError>(error: ECHOError.internalError(error))
            completion(result)
        case .result:
            let result = Result<Void, ECHOError>(value: ())
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<Void, ECHOError>(error: error)
        completion(result)
    }
}
