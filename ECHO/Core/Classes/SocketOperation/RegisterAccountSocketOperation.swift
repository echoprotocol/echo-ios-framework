//
//  RegisterAccountSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 15/01/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

struct RegisterAccountSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var name: String
    var activeKey: String
    var echorandKey: String
    var completion: Completion<Bool>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.registerAccount.rawValue,
                            [operationId, name, activeKey, echorandKey]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        switch response.response {
        case .error(let error):
            let result = Result<Bool, ECHOError>(error: ECHOError.internalError(error.message))
            completion(result)
        case .result(_):
            let result = Result<Bool, ECHOError>(value: true)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<Bool, ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
