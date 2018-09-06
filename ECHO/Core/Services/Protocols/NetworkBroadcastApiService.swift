//
//  NetworkBroadcastApiService.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

/**
     Encapsulates logic, associated with blockchain network broadcast API

    - Note: [Graphene blockchain network broadcast API](https://dev-doc.myecho.app/classgraphene_1_1app_1_1network__broadcast__api.html)
 */
protocol NetworkBroadcastApiService: class {
    
    init(socketCore: SocketCoreComponent)
    
    func broadcastTransactionWithCallback(transaction: Transaction, completion: @escaping Completion<Bool>)
}
