//
//  CryptoApiService.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

/**
    Encapsulates logic, associated with blockchain crypto API
 
    - Note: [Graphene blockchain crypto API](https://dev-doc.myecho.app/classgraphene_1_1app_1_1crypto__api.html)
 */
protocol CryptoApiService {
    
    init(socketCore: SocketCoreComponent)
}
