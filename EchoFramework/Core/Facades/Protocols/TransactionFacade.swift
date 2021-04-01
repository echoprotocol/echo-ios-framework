//
//  TransactionFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    The interface of the class that allows you to send transactions.
 */
public protocol TransactionFacade {
        
/**
     This is a function for sending funds.
     
     - Parameter fromNameOrId: Sender name or id
     - Parameter wif: Sender wif from account
     - Parameter toNameOrId: Receiver name or id
     - Parameter amount: Amount
     - Parameter asset: Id of asset which is sent
     - Parameter assetForFee: Id of asset which is pay fee
     - Parameter sendCompletion: Callback in which the information will return transaction ID or errror
     - Parameter confirmNoticeHandler: Callback in which the information will return whether the transaction was confirmed or not
     
     - Remark:
     Default asset is **"1.3.0"**
 */
    func sendTransferOperation(
        fromNameOrId: String,
        wif: String,
        toNameOrId: String,
        amount: UInt,
        asset: String,
        assetForFee: String?,
        sendCompletion: @escaping Completion<String>,
        confirmNoticeHandler: NoticeHandler?
    )
}
