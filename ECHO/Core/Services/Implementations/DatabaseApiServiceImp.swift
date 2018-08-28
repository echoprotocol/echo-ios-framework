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
    
    func getFullAccount(nameOrIds: [String], shoudSubscribe: Bool, completion: @escaping Completion<[String: UserAccount]>) {
        
        let operation = FullAccountSocketOperation(method: .call,
                                                   operationId: socketCore.nextOperationId(),
                                                   apiId: apiIdentifire,
                                                   accountsIds: nameOrIds,
                                                   shoudSubscribe: shoudSubscribe,
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
    
    func getBlock(blockNumber: Int, completion: @escaping (Result<Block, ECHOError>) -> Void) {
        
        let operation = GetBlockSocketOperation(method: .call,
                                                operationId: socketCore.nextOperationId(),
                                                apiId: apiIdentifire,
                                                blockNumber: blockNumber,
                                                completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func getRequiredFees(operations: [BaseOperation], asset: Asset, completion: @escaping Completion<[AssetAmount]>) {
        
        let operation = RequiredFeeSocketOperation(method: .call,
                                                   operationId: socketCore.nextOperationId(),
                                                   apiId: apiIdentifire,
                                                   operations: operations,
                                                   asset: asset,
                                                   completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func setSubscribeCallback(completion: @escaping Completion<Bool>) {
        let operation = SetSubscribeCallbackSocketOperation(method: .call,
                                                            operationId: socketCore.nextOperationId(),
                                                            apiId: apiIdentifire,
                                                            needClearFilter: false,
                                                            completion: completion)
        socketCore.send(operation: operation)
    }
}
