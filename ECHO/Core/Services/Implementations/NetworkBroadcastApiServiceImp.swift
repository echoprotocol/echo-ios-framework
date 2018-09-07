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
    
    func broadcastTransactionWithCallback(transaction: Transaction, completion: @escaping Completion<Bool>) {
        
        let operation = TransactionSocketOperation(method: .call,
                                                   operationId: socketCore.nextOperationId(),
                                                   apiId: apiIdentifire,
                                                   transaction: transaction,
                                                   completion: completion)
        
        socketCore.send(operation: operation)
    }
}
