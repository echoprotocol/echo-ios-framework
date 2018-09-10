//
//  ContractsFacadeImp.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 10.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Services for TransactionFacade
 */
public struct ContractsFacadeServices {
    var databaseService: DatabaseApiService
    var networkBroadcastService: NetworkBroadcastApiService
}

/**
    Implementation of [ContractsFacade](ContractsFacade), [ECHOQueueble](ECHOQueueble)
 */
final public class ContractsFacadeImp: ContractsFacade, ECHOQueueble {
    
    var queues: [ECHOQueue]
    let services: ContractsFacadeServices
    let network: Network
    let cryptoCore: CryptoCoreComponent
    
    public init(services: ContractsFacadeServices, cryptoCore: CryptoCoreComponent, network: Network) {
        
        self.services = services
        self.network = network
        self.cryptoCore = cryptoCore
        self.queues = [ECHOQueue]()
    }
    
    public func getContractResult(historyId: String, completion: @escaping Completion<ContractResult>) {
        
        services.databaseService.getContractResult(historyId: historyId, completion: completion)
    }
    
    public func getContracts(contractIds: [String], completion: @escaping Completion<[ContractInfo]>) {
        
        services.databaseService.getContracts(contractIds: contractIds, completion: completion)
    }
    
    public func getAllContracts(completion: @escaping Completion<[ContractInfo]>) {
        
        services.databaseService.getAllContracts(completion: completion)
    }
    
    public func getContract(contractId: String, completion: @escaping Completion<ContractStruct>) {
        
        services.databaseService.getContract(contractId: contractId, completion: completion)
    }
}
