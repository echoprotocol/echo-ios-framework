//
//  AccountHistoryApiServiceImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

final class AccountHistoryApiServiceImp: AccountHistoryApiService, ApiIdentifireHolder {
    
    var apiIdentifire: Int = 0
    
    let socketCore: SocketCoreComponent
    
    required init(socketCore: SocketCoreComponent) {
        self.socketCore = socketCore
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
