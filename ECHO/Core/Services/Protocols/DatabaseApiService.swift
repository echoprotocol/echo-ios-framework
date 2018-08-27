//
//  DatabaseApiService.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

protocol DatabaseApiService {
    
    init(socketCore: SocketCoreComponent)
    func getFullAccount(nameOrIds: [String], shoudSubscribe: Bool, completion: @escaping Completion<[UserAccount]>) 
    func getBlockData(completion: @escaping Completion<BlockData>)
    func getBlock(blockNumber: Int, completion: @escaping Completion<Block>)
    func setSubscribeCallback(completion: @escaping Completion<Bool>)
}
