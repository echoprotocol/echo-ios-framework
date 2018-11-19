//
//  CryptoApiServiceImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Implementation of [CryptoApiService](CryptoApiService)
 
    Encapsulates logic of preparing API calls to [SocketCoreComponent](SocketCoreComponent)
 */
final class CryptoApiServiceImp: CryptoApiService {
    var apiIdentifire: Int = 0
    
    let socketCore: SocketCoreComponent
    
    required init(socketCore: SocketCoreComponent) {
        self.socketCore = socketCore
    }
    
    func sendCustomOperation(operation: CustomSocketOperation) {
        
        operation.setApiId(apiIdentifire)
        operation.setOperationId(socketCore.nextOperationId())
        
        socketCore.send(operation: operation)
    }
}
