//
//  DatabaseApiService.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Encapsulates logic, associated with blockchain database API
 
    [Graphene blockchain database API](https://dev-doc.myecho.app/classgraphene_1_1app_1_1database__api.html)
 */
protocol DatabaseApiService: class {
    
    init(socketCore: SocketCoreComponent)
    
/**
     Retrieves base block information

     - Parameter completion: Callback which returns current block data or error
 */
    func getBlockData(completion: @escaping Completion<BlockData>)
    
/**
    Retrieves full signed block

     - Parameter blockNumber: Height of the block to be returned
     - Parameter completion: Callback which returns Block or error
 */
    func getBlock(blockNumber: Int, completion: @escaping Completion<Block>)
    
/**
     Retrieves blockchain chain id
     
     - Parameter completion: Callback which returns chain id string or error
 */
    func getChainId(completion: @escaping Completion<String>)
    
/**
     Fetch all objects relevant to the specified accounts and subscribe to updates.
     
     - Parameter nameOrIds: Each item must be the name or ID of an account to retrieve
     - Parameter shoudSubscribe: Flag for subscribe options, true if need to subscribe on changes
     - Parameter completion: Callback which returns accounts or error
 */
    func getFullAccount(nameOrIds: [String], shoudSubscribe: Bool, completion: @escaping Completion<[String: UserAccount]>)
    
/**
    Retrieves required fee by asset for ech operation

     - Parameter operations: Operations for getting fee
     - Parameter asset: Asset type for fee paying
     - Parameter completion: Callback which returns amounts or error
 */
    func getRequiredFees(operations: [BaseOperation], asset: Asset, completion: @escaping Completion<[AssetAmount]>)
    
/**
     Subscribes to listening chain objects

     - Parameter completion: Callback which returns status of subscription
 */
    func setSubscribeCallback(completion: @escaping Completion<Bool>)
    
/**
     Query list of assets by required asset symbol [lowerBound] with limit [limit]
 */
    func getAssets(assetIds: [String], completion: @escaping Completion<[Asset]>)
    
/**
     Query list of assets by it's ids [assetIds]
 */
    func listAssets(lowerBound: String, limit: Int, completion: @escaping Completion<[Asset]>)
}
