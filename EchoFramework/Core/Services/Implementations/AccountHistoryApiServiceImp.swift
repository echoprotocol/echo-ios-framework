//
//  AccountHistoryApiServiceImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Implementation of [AccountHistoryApiService](AccountHistoryApiService)
 
    Encapsulates logic of preparing API calls to [SocketCoreComponent](SocketCoreComponent)
 */
final class AccountHistoryApiServiceImp: AccountHistoryApiService {
    
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
    
    func getAccountHistory(id: String,
                           startId: String,
                           stopId: String,
                           limit: Int,
                           completion: @escaping Completion<[HistoryItem]>) {
        
        let operation = GetAccountHistorySocketOperation(method: .call,
                                                         operationId: socketCore.nextOperationId(),
                                                         apiId: apiIdentifire,
                                                         accountId: id,
                                                         stopId: stopId,
                                                         limit: limit,
                                                         startId: startId,
                                                         completion: completion)
        
        socketCore.send(operation: operation)
    }
}
