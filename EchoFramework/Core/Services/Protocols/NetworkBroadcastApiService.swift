//
//  NetworkBroadcastApiService.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
     Encapsulates logic, associated with blockchain network broadcast API

    - Note: [Graphene blockchain network broadcast API](https://dev-doc.myecho.app/classgraphene_1_1app_1_1network__broadcast__api.html)
*/
protocol NetworkBroadcastApiService: BaseApiService {
    
    /**
    Broadcast a transaction to the network.
 
    - Parameter transaction: Transaction whitch need to send to the netword
    - Parameter completion: Callback which returns transaction ID or error
    - Returns: ID of operation
     */
    func broadcastTransactionWithCallback(transaction: Transaction, completion: @escaping Completion<String>) -> Int
}
