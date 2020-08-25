//
//  InformationFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    The interface of the class that provides information about a user's account
 */
public protocol InformationFacade {
    
/**
     Get the objects corresponding to the provided IDs.
     
     - Parameter objectsIds: IDs of the objects to retrieve
     - Parameter completion: Callback which returns current block data or error
 */
    func getObjects<T>(
        type: T.Type,
        objectsIds: [String],
        completion: @escaping Completion<[T]>
    ) where T: Decodable
    
/**
     Retrieves full signed block
     
     - Parameter blockNumber: Height of the block to be returned
     - Parameter completion: Callback which returns Block or error
 */
    func getBlock(
        blockNumber: Int,
        completion: @escaping Completion<Block>
    )
    
/**
     Register new account in blockchain
     
     - Parameter name: The name of new account
     - Parameter wif: The wif wich will be used for create private keys
     - Parameter evmAddress: EVM address that will be assosiated with account
     - Parameter sendCompletion: Callback in which the information will return whether the transaction was successful send to chain.
     - Parameter confirmNoticeHandler: Callback in which the information will return whether the transaction was confirmed or not.     
 */
    func registerAccount(
        name: String,
        wif: String,
        evmAddress: String?,
        sendCompletion: @escaping Completion<Void>,
        confirmNoticeHandler: NoticeHandler?
    )
    
/**
     Account function
     
     - Parameter nameOrID: Name or id of the account
     - Parameter completion: Callback in which the information will return account or error.
 */
    func getAccount(
        nameOrID: String,
        completion: @escaping Completion<Account>
    )
    
/**
     The function to check if there is an account
     
     - Parameter nameOrID: Name or id of the account
     - Parameter completion: Callback which returns true if there is such account, false if there is no or error
 */
    func isAccountReserved(
        nameOrID: String,
        completion: @escaping Completion<Bool>
    )
    
/**
     Account balance function
     
     - Parameter nameOrID: Name or id of the account
     - Parameter asset: Id of asset
     - Parameter completion: Callback which returns balances for a given asset or error
 */
    func getBalance(
        nameOrID: String,
        asset: String?,
        completion: @escaping Completion<[AccountBalance]>
    )
    
/**
     Function for getting account history
     
     - Parameter nameOrID: Name or id of the account
     - Parameter startId: ID of the starting element of history
     - Parameter stopId: ID of the last element of the story
     - Parameter limit: Number of items in history
     - Parameter completion: Callback which returns history for account or error
     - Note: To get the entire history, you can specify the initial id **"1.11.0"** in the start ID and stop ID and then choose your limit
 */
    func getAccountHistroy(
        nameOrID: String,
        startId: String,
        stopId: String,
        limit: Int,
        completion: @escaping Completion<[HistoryItem]>
    )
    
/**
     Retrieve the current global property object.

     - Parameter completion: Callback which returns [GlobalProperties](GlobalProperties) or error
 */
    func getGlobalProperties(completion: @escaping Completion<GlobalProperties>)
}
