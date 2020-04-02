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
    
    func requestRegistrationTask(completion: @escaping Completion<RegistrationTask>) {
        
        let operationID = socketCore.nextOperationId()
        let operation = RequestRegistrationTaskSocketOperation(method: .call,
                                                               operationId: operationID,
                                                               apiId: apiIdentifire,
                                                               completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func submitRegistrationSolution(name: String,
                                    activeKey: String,
                                    echorandKey: String,
                                    evmAddress: String?,
                                    nonce: UInt,
                                    randNum: UInt,
                                    completion: @escaping Completion<Bool>) -> Int {
        
        let operationID = socketCore.nextOperationId()
        let operation = SubmitRegistrationSolutionSocketOperation(
            method: .call,
            operationId: operationID,
            apiId: apiIdentifire,
            name: name,
            activeKey: activeKey,
            echorandKey: echorandKey,
            evmAddress: evmAddress,
            nonce: nonce,
            randNum: randNum,
            completion: completion
        )
        
        socketCore.send(operation: operation)
        return operationID
    }
}
