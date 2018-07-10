//
//  AuthentificationFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

protocol AuthentificationFacade {
    func login(name: String, password: String, completion: Completion<UserAccount>)
    func changePassword(old: String, new: String, name: String, completion: Completion<UserAccount>)
}
