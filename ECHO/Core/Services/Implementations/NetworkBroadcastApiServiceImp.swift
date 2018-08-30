//
//  NetworkBroadcastApiServiceImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

class NetworkBroadcastApiServiceImp: NetworkBroadcastApiService, ApiIdentifireHolder {
    
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
