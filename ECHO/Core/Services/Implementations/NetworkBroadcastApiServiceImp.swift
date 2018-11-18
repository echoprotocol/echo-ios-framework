//
//  NetworkBroadcastApiServiceImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Implementation of [NetworkBroadcastApiService](NetworkBroadcastApiService)
 
    Encapsulates logic of preparing API calls to [SocketCoreComponent](SocketCoreComponent)
 */
final class NetworkBroadcastApiServiceImp: NetworkBroadcastApiService, ApiIdentifireHolder {
    
    var apiIdentifire: Int = 0
    
    let socketCore: SocketCoreComponent
    
    required init(socketCore: SocketCoreComponent) {
        self.socketCore = socketCore
    }
    
    func broadcastTransactionWithCallback(transaction: Transaction, completion: @escaping Completion<Bool>) -> Int {
        
        let operationId = socketCore.nextOperationId()
        let operation = TransactionWithCallbackSocketOperation(method: .call,
                                                               operationId: operationId,
                                                               apiId: apiIdentifire,
                                                               transaction: transaction,
                                                               completion: completion,
                                                               notifyHandler: nil)
        
        socketCore.send(operation: operation)
        return operationId
    }
}
