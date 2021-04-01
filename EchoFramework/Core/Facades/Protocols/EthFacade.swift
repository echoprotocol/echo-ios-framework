//
//  EthFacade.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 20/05/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    The interface of the class that allows you to work with Ethereum sidechain part of blockchain.
 */
public protocol EthFacade {
    
/**
     Create address in Ethereum network
     
     - Parameter nameOrId: Name or id
     - Parameter wif: Sender wif from account
     - Parameter assetForFee: Id of asset which is pay fee
     - Parameter sendCompletion: Callback in which the information will return transaction ID or error
     - Parameter confirmNoticeHandler: Callback in which the information will return whether the transaction was confirmed or not.
     
     - Remark:
     Default asset is **"1.3.0"**
 */
    func generateEthAddress(
        nameOrId: String,
        wif: String,
        assetForFee: String?,
        sendCompletion: @escaping Completion<String>,
        confirmNoticeHandler: NoticeHandler?
    )
    
/**
     Get created Ethereum addresses
 
     - Parameter nameOrId: Name or id
     - Parameter completion: Callback in which the information will return [EthAddress](EthAddress) object (if it was created) or error
 */
    func getEthAddress(
        nameOrId: String,
        completion: @escaping Completion<EthAddress?>
    )
    
/**
     Send ETH to Ethereum network to Ethereum address
     
     - Parameter nameOrId: Name or id
     - Parameter wif: Sender wif from account
     - Parameter toEthAddress: Receiver ethereum address
     - Parameter amount: Amount
     - Parameter assetForFee: Id of asset which is pay fee
     - Parameter sendCompletion: Callback in which the information will return transaction ID or error
     - Parameter confirmNoticeHandler: Callback in which the information will return whether the transaction was confirmed or not.
 */
    func withdrawEth(
        nameOrId: String,
        wif: String,
        toEthAddress: String,
        amount: UInt,
        assetForFee: String?,
        sendCompletion: @escaping Completion<String>,
        confirmNoticeHandler: NoticeHandler?
    )
    
/**
     Returns all approved deposits, for the given account id or name.
 
     - Parameter nameOrId: Name or id
     - Parameter completion: Callback in which return Deposits objects or error.
 */
    func getEthAccountDeposits(
        nameOrId: String,
        completion: @escaping Completion<[EthDeposit]>
    )
    
/**
     Returns all approved withdrawals, for the given account id or name.
     
     - Parameter nameOrId: Name or id
     - Parameter completion: Callback in which return Withdrawals objects or error.
 */
    func getEthAccountWithdrawals(
        nameOrId: String,
        completion: @escaping Completion<[EthWithdrawal]>
    )
}
