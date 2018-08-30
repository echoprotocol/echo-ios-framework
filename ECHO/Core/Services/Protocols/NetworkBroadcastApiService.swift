//
//  NetworkBroadcastApiService.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

protocol NetworkBroadcastApiService {
    
    init(socketCore: SocketCoreComponent)
    
    func broadcastTransactionWithCallback(transaction: Transaction, completion: @escaping Completion<Bool>)
}
