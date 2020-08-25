//
//  AuthentificationFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    The interface of the class that is responsible for verifying user authorization and changing its parameters.
 */
public protocol AuthentificationFacade {

/**
     Generate random EDDSA private key and return it represented in WIF format
 
     - Returns: private key in WIF format
 */
    func generateRandomWIF() -> String
    
/**
     A function that checks if the wif for this account
     
     - Parameter name: Account name or id
     - Parameter wif: WIF
     - Parameter completion: Callback which returns an account or error
 */
    func isOwnedBy(
        name: String,
        wif: String,
        completion: @escaping Completion<UserAccount>
    )
    
/**
     A function that checks if accounts registered in chain with public keys from WIF and return them
     
     - Parameter wif: WIF of account that needs to check
     - Parameter completion: Callback which returns an an array of accounts or error
*/
    func isOwnedBy(
        wif: String,
        completion: @escaping Completion<[UserAccount]>
    )
    
/**
     Function for changing the account keys
     
     - Parameter oldWIF: Old account WIF
     - Parameter newWIF: New account WIF
     - Parameter name: Account name or id
     - Parameter sendCompletion: Callback in which the information will return whether the transaction was successful send to chain.
     - Parameter confirmNoticeHandler: Callback in which the information will return whether the transaction was confirmed or not.
 */
    func changeKeys(
        oldWIF: String,
        newWIF: String,
        name: String,
        sendCompletion: @escaping Completion<Void>,
        confirmNoticeHandler: NoticeHandler?
    )
}
