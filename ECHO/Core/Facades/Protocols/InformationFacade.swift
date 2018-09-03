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
     Account function
     
     - Parameter nameOrID: Name or id of the account
     - Parameter completion: Callback in which the information will return account or error.
 */
    func getAccount(nameOrID: String, completion: @escaping Completion<Account>)
    
/**
     The function to check if there is an account
     
     - Parameter nameOrID: Name or id of the account
     - Parameter completion: Callback which returns true if there is such account, false if there is no or error
 */
    func isAccountReserved(nameOrID: String, completion: @escaping Completion<Bool>)
    
/**
     Account balance function
     
     - Parameter nameOrID: Name or id of the account
     - Parameter asset: Id of asset
     - Parameter completion: Callback which returns balances for a given asset or error
 */
    func getBalance(nameOrID: String, asset: String?, completion: @escaping Completion<[AccountBalance]>)
    
/**
     Function for getting account history
     
     - Parameter nameOrID: Name or id of the account
     - Parameter startId: ID of the starting element of history
     - Parameter stopId: ID of the last element of the story
     - Parameter limit: Number of items in history
     - Parameter completion: Callback which returns history for account or error
     - Note: To get the entire history, you can specify the initial id **"1.11.0"** in the start ID and stop ID and then choose your limit
 */
    func getAccountHistroy(nameOrID: String, startId: String, stopId: String, limit: Int, completion: @escaping Completion<[HistoryItem]>)
}
