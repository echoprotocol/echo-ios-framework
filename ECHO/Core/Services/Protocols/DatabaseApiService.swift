//
//  DatabaseApiService.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

protocol DatabaseApiService {
    
    init(socketCore: SocketCoreComponent)
    func getFullAccount(nameOrIds: [String], completion: @escaping Completion<UserAccount>)
}
