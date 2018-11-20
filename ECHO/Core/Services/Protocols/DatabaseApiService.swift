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
protocol DatabaseApiService: BaseApiService {
    
/**
    Get the objects corresponding to the provided IDs.
     
    - Parameter objectsIds: IDs of the objects to retrieve
    - Parameter completion: Callback which returns current block data or error
 */
    func getObjects<T>(type: T.Type, objectsIds: [String], completion: @escaping Completion<[T]>) where T: Decodable
    
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
     Subscribes to listening chain objects
     
     - Parameter completion: Callback which returns status of subscription
 */
    func setBlockAppliedCallback(blockId: String, completion: @escaping Completion<Bool>)
    
/**
     Query list of assets by it's ids [assetIds]
     
     - Parameter assetIds: Assets Ids for getting information
     - Parameter completion: Callback which returns [[Asset](Asset)] or error
 */
    func getAssets(assetIds: [String], completion: @escaping Completion<[Asset]>)
    
/**
     Query list of assets by required asset symbol [lowerBound] with limit [limit]
     
     - Parameter lowerBound: Id of aseet used as lower bound
     - Parameter limit: Count of getting assets
     - Parameter completion: Callback which returns [[Asset](Asset)] or error
 */
    func listAssets(lowerBound: String, limit: Int, completion: @escaping Completion<[Asset]>)
    
/**
     Return result of contract operation call
     
     - Parameter lowerBound: Hisory id for find contract result
     - Parameter completion: Callback which returns [ContractResult](ContractResult) or error
 */
    func getContractResult(historyId: String, completion: @escaping Completion<ContractResult>)
    
/**
    Return list of contract logs
     
     - Parameter contractId: Contract id for fetching logs
     - Parameter fromBlockId: Number of the earliest block to retrieve
     - Parameter toBlockId: Number of the most recent block to retrieve
     - Parameter completion: Callback which returns an array of [ContractLog](ContractLog) result of call or error
 */
    func getContractLogs(contractId: String, fromBlock: Int, toBlock: Int, completion: @escaping Completion<[ContractLog]>)
    
/**
     Subscribes to listening contract logs
     
     - Parameter contractId: Contract id for fetching logs
     - Parameter fromBlockId: Number of the earliest block to retrieve
     - Parameter toBlockId: Number of the most recent block to retrieve
     - Parameter completion: Callback which returns an array of [ContractLog](ContractLog) result of call or error
f */
    func subscribeContractLogs(contractId: String, fromBlock: Int, toBlock: Int, completion: @escaping Completion<[ContractLog]>)
/**
     Returns contracts called by ids
     
     - Parameter contractIds: Contracts ids for call
     - Parameter completion: Callback which returns an [[ContractInfo](ContractInfo)] or error
 */
    func getContracts(contractIds: [String], completion: @escaping Completion<[ContractInfo]>)
    
/**
     Returns all existing contracts from blockchain
     
     - Parameter completion: Callback which returns an [[ContractInfo](ContractInfo)] or error
 */
    func getAllContracts(completion: @escaping Completion<[ContractInfo]>)
    
/**
     Return full information about contract
     
     - Parameter contractId: Identifier for contract
     - Parameter completion: Callback which returns an [ContractStruct](ContractStruct) or error
 */
    func getContract(contractId: String, completion: @escaping Completion<ContractStruct>)
    
/**
     Calls contract method without changing state of blockchain
     
     - Parameter contract: Called contract
     - Parameter asset: Asset of contract
     - Parameter account: Account that call the contract
     - Parameter contractCode: Contract code for execute
     - Parameter completion: Callback which returns an [Bool](Bool) result of call or error
 */
    func callContractNoChangingState(contract: Contract,
                                     asset: Asset,
                                     account: Account,
                                     contractCode: String,
                                     completion: @escaping Completion<String>)
}
