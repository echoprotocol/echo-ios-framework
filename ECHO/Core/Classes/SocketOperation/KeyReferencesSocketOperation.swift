//
//  KeyReferencesSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Get all account references
 
    - Return: [Any](Any)
 
    - Note: Not completed
 */
struct KeyReferencesSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var completion: Completion<Any>
    var publicKey: String
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.keyReference.rawValue,
                            [[publicKey]]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
    }
}
