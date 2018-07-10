//
//  InformationFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

protocol InformationFacade {
    func getAccount(nameOrID: String, completion: Completion<UserAccount>)
    func isAccauntReserved(nameOrID: String, completion: Completion<Bool>)
    func getBalance(nameOrID: String, asset: String, completion: Completion<Int>)
}
