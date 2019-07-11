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
     A function that checks if the password for this account
     
     - Parameter name: Account name or id
     - Parameter wif: WIF
     - Parameter completion: Callback which returns an account or error
 */
    func isOwnedBy(name: String, wif: String, completion: @escaping Completion<UserAccount>)
    
/**
     A function that checks if accounts registered in chain with public keys from WIF and return them
     
     - Parameter wif: WIF of account that needs to check
     - Parameter completion: Callback which returns an an array of accounts or error
*/
    func isOwnedBy(wif: String, completion: @escaping Completion<[UserAccount]>)
    
/**
     Function for changing the account keys
     
     - Parameter oldWIF: Old account WIF
     - Parameter newWIF: New account WIF
     - Parameter name: Account name or id
     - Parameter completion: Callback in which the information will return whether the change password was successful
 */
    func changeKeys(oldWIF: String, newWIF: String, name: String, completion: @escaping Completion<Bool>)
}
