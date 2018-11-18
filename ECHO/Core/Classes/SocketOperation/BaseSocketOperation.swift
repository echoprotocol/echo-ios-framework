//
//  BaseSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct BaseSocketOperation: SocketOperation {
    
    typealias Result = Bool
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var completion: Completion<Any>
    
    func createParameters() -> [Any] {
        return []
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
    }
}
