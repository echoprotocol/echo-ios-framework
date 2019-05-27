//
//  EthFacade.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 20/05/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    The interface of the class that allows you to work with sidechain part of blockchain.
 */
public protocol EthFacade {
    
/**
     Create eth account address in ETH network
     
     - Parameter nameOrId: Name or id
     - Parameter passwordOrWif: Sender password or wif from account
     - Parameter assetForFee: Id of asset which is pay fee
     - Parameter completion: Callback in which the information will return whether the transaction was successful.
     
     - Remark:
     Default asset is **"1.3.0"**
 */
    func generateEthAddress(nameOrId: String,
                            passwordOrWif: PassOrWif,
                            assetForFee: String?,
                            completion: @escaping Completion<Bool>,
                            noticeHandler: NoticeHandler?)
    
/**
     Get created ETH addresses
 
     - Parameter nameOrId: Name or id
     - Parameter completion: Callback in which the information will return [EthAddress](EthAddress) objects or error
 */
    func getEthAddress(nameOrId: String,
                       completion: @escaping Completion<[EthAddress]>)
    
/**
     Send ETH to Ethereum network to ethAddress
     
     - Parameter nameOrId: Name or id
     - Parameter passwordOrWif: Sender password or wif from account
     - Parameter toEthAddress: Receiver eth address
     - Parameter amount: Amount
     - Parameter completion: Callback in which the information will return whether the transaction was successful.
 */
    func withdrawalEth(nameOrId: String,
                       passwordOrWif: PassOrWif,
                       toEthAddress: String,
                       amount: UInt,
                       assetForFee: String?,
                       completion: @escaping Completion<Bool>,
                       noticeHandler: NoticeHandler?)
}
