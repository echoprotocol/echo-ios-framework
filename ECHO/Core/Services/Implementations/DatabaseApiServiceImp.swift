//
//  DatabaseApiServiceImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

class DatabaseApiServiceImp: DatabaseApiService, ApiIdentifireHolder {
    
    var apiIdentifire: Int = 0
    let socketCore: SocketCoreComponent
    
    required init(socketCore: SocketCoreComponent) {
        self.socketCore = socketCore
    }
    
    func getFullAccount(nameOrIds: [String], completion: @escaping Completion<UserAccount>) {
        
        let operation = FullAccountSocketOperation(method: .call,
                                                   operationId: socketCore.nextOperationId(),
                                                   apiId: apiIdentifire,
                                                   accountsIds: nameOrIds,
                                                   shoudSubscribe: false,
                                                   completion: completion) 
        
        socketCore.send(operation: operation)
    }
    
    func getBlockData(completion: @escaping Completion<BlockData>) {
        
        let operation = BlockDataSocketOperation(method: .call,
                                                 operationId: socketCore.nextOperationId(),
                                                 apiId: apiIdentifire,
                                                 completion: completion)
        
        socketCore.send(operation: operation)
    }

}
