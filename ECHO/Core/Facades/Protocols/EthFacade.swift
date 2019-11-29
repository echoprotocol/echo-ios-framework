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
     - Parameter wif: Sender wif from account
     - Parameter assetForFee: Id of asset which is pay fee
     - Parameter completion: Callback in which the information will return whether the transaction was successful.
     - Parameter noticeHandler: Callback in which the information will return whether the transaction was confirmed.
     
     - Remark:
     Default asset is **"1.3.0"**
 */
    func generateEthAddress(nameOrId: String,
                            wif: String,
                            assetForFee: String?,
                            completion: @escaping Completion<Bool>,
                            noticeHandler: NoticeHandler?)
    
/**
     Get created ETH addresses
 
     - Parameter nameOrId: Name or id
     - Parameter completion: Callback in which the information will return [EthAddress](EthAddress) object (if it created) or error
 */
    func getEthAddress(nameOrId: String,
                       completion: @escaping Completion<EthAddress?>)
    
/**
     Send ETH to Ethereum network to ethAddress
     
     - Parameter nameOrId: Name or id
     - Parameter wif: Sender wif from account
     - Parameter toEthAddress: Receiver eth address
     - Parameter amount: Amount
     - Parameter completion: Callback in which the information will return whether the transaction was successful.
     - Parameter noticeHandler: Callback in which the information will return whether the transaction was confirmed.     
 */
    func withdrawalEth(nameOrId: String,
                       wif: String,
                       toEthAddress: String,
                       amount: UInt,
                       assetForFee: String?,
                       completion: @escaping Completion<Bool>,
                       noticeHandler: NoticeHandler?)
    
/**
     Returns all approved deposits, for the given account id or name.
 
     - Parameter nameOrId: Name or id
     - Parameter completion: Callback in which return Deposits objects or error.
 */
    func getAccountDeposits(nameOrId: String,
                            completion: @escaping Completion<[EthDeposit]>)
    
/**
     Returns all approved withdrawals, for the given account id or name.
     
     - Parameter nameOrId: Name or id
     - Parameter completion: Callback in which return Withdrawals objects or error.
 */
    func getAccountWithdrawals(nameOrId: String,
                               completion: @escaping Completion<[EthWithdrawal]>)
}
