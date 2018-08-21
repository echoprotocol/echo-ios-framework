//
//  NetworkNodesApiServiceImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

class NetworkNodesApiServiceImp: NetworkNodesApiService, ApiIdentifireHolder {
    
    var apiIdentifire: Int = 0
    
    let socketCore: SocketCoreComponent
    
    required init(socketCore: SocketCoreComponent) {
        self.socketCore = socketCore
    }
}
