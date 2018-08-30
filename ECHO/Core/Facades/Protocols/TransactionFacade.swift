//
//  TransactionFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public protocol TransactionFacade {
    
    func sendTransferOperation(fromNameOrId: String,
                               password: String,
                               toNameOrId: String,
                               amount: UInt,
                               asset: String,
                               message: String?,
                               completion: @escaping Completion<Bool>)
}
