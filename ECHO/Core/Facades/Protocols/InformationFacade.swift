//
//  InformationFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public protocol InformationFacade {
    func getAccount(nameOrID: String, completion: @escaping Completion<Account>)
    func isAccauntReserved(nameOrID: String, completion: @escaping Completion<Bool>)
    func getBalance(nameOrID: String, asset: String?, completion: @escaping Completion<[AccountBalance]>)
}
