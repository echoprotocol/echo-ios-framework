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
    func isOwnedBy(name: String, password: String, completion: @escaping Completion<UserAccount>)
    func changePassword(old: String, new: String, name: String, completion: @escaping Completion<UserAccount>)
}
