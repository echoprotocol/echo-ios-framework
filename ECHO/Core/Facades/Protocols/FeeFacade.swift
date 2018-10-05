//
//  FeeFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    The interface of the class that is responsible for the fee cost of the operation
 */
public protocol FeeFacade {
    
/**
     Function for evaluating the fee of transfer operation
     
     - Parameter fromNameOrId: Sender name or id
     - Parameter toNameOrId: Receiver name or id
     - Parameter amount: Amount
     - Parameter asset: Id of asset which is sent
     - Parameter assetForFee: Id of asset which is pay fee
     - Parameter message: Message into transaction
     - Parameter completion: Callback which returns fee for operation or error
 */
    func getFeeForTransferOperation(fromNameOrId: String,
                                    toNameOrId: String,
                                    amount: UInt,
                                    asset: String,
                                    assetForFee: String?,
                                    message: String?,
                                    completion: @escaping Completion<AssetAmount>)
}
