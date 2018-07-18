//
//  RequiredFeeSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct RequiredFeeSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var completion: Completion<Any>
    var publicKey: String
    var operations: [Any]
    var assetId: String
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.requiredFee.rawValue,
                            [operationId, assetId]]
        return array
    }
    
    func complete(json: [String: Any]) {
        
    }
}
