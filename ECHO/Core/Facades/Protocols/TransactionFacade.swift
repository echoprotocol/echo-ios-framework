//
//  TransactionFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

protocol TransactionFacade {
    func sendTransferOperation(nameOrId: String,
                               password: String,
                               toNameOrID: String,
                               amount: String,
                               asset: String,
                               completion: Completion<String>)
    
    func getAccountHistory(nameOrId: String,
                           transactionStopId: String,
                           limit: Int,
                           transactionStartId: String,
                           asset: String,
                           completion: Completion<HistoryItem>)
}
