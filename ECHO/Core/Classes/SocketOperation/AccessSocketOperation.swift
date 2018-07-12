//
//  AccessSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

enum AccessSocketOperationType: String {
    case login
    case database
    case networkBroadcast = "network_broadcast"
    case history
    case crypto
}

struct AccessSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var completion: Completion<OperationResult<Any>>
    var type: AccessSocketOperationType
    
    init(type: AccessSocketOperationType,
         method: SocketOperationType,
         operationId: Int,
         completion: @escaping Completion<OperationResult<Any>>) {
        
        self.type = type
        self.method = method
        self.operationId = operationId
        self.apiId = 1
        self.completion = completion
    }
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            type.rawValue,
                            getArrayForParams()]
        return array
    }
    
    fileprivate func getArrayForParams() -> [Any] {
        switch type {
        case .login:
            return ["", ""]
        case .crypto, .history, .database, .networkBroadcast:
            return []
        }
    }
}
