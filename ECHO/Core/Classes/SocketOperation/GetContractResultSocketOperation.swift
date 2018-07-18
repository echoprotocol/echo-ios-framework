//
//  GetContractResultSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct GetContractResultSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var completion: Completion<Any>
    var resultId: String
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.contractResult.rawValue,
                            [resultId]]
        return array
    }
    
    func complete(json: [String: Any]) {
        
    }
}
