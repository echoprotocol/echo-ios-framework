//
//  RegistrationApiServiceImp.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 15/01/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
 Implementation of [RegistrationApiService](RegistrationApiService)
 
 Encapsulates logic of preparing API calls to [SocketCoreComponent](SocketCoreComponent)
 */
final class RegistrationApiServiceImp: RegistrationApiService {
    
    var apiIdentifire: Int = 5
    
    let socketCore: SocketCoreComponent
    
    required init(socketCore: SocketCoreComponent) {
        self.socketCore = socketCore
    }
    
    func sendCustomOperation(operation: CustomSocketOperation) {
        
        operation.setApiId(apiIdentifire)
        operation.setOperationId(socketCore.nextOperationId())
        
        socketCore.send(operation: operation)
    }
    
    func registerAccount(name: String,
                         ownerKey: String,
                         activeKey: String,
                         memoKey: String,
                         echorandKey: String,
                         completion: @escaping Completion<Bool>) -> Int {
        
        let operationID = socketCore.nextOperationId()
        let operation = RegisterAccountSocketOperation(method: .call,
                                                       operationId: operationID,
                                                       apiId: apiIdentifire,
                                                       name: name,
                                                       ownerKey: ownerKey,
                                                       activeKey: activeKey,
                                                       memoKey: memoKey,
                                                       echorandKey: echorandKey,
                                                       completion: completion)
        
        socketCore.send(operation: operation)
        return operationID
    }
}
