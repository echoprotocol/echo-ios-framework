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
     - Parameter password: Password
     - Parameter completion: Callback which returns an account or error
 */
    func isOwnedBy(name: String, password: String, completion: @escaping Completion<UserAccount>)
    
/**
     Function for changing the password
     
     - Parameter old: Old account password
     - Parameter new: New account password
     - Parameter name: Account name or id
     - Parameter completion: Callback in which the information will return whether the change password was successful
 */
    func changePassword(old: String, new: String, name: String, completion: @escaping Completion<Bool>)
}
