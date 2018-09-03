//
//  NetworkNodesApiServiceImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

/**
    Implementation of [NetworkNodesApiService](NetworkNodesApiService)
 
    Encapsulates logic of preparing API calls to [SocketCoreComponent](SocketCoreComponent)
 */
final class NetworkNodesApiServiceImp: NetworkNodesApiService, ApiIdentifireHolder {
    
    var apiIdentifire: Int = 0
    
    let socketCore: SocketCoreComponent
    
    required init(socketCore: SocketCoreComponent) {
        self.socketCore = socketCore
    }
}
