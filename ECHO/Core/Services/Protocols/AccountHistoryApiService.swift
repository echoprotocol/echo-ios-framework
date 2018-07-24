//
//  AccountHistoryApiService.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

protocol AccountHistoryApiService {
    
    init(socketCore: SocketCoreComponent)
    
    func getAccountHistory(id: String,
                           startId: String,
                           stopId: String,
                           limit: Int,
                           completion: @escaping Completion<[Any]>)
}
