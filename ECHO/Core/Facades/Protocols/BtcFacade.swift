//
//  BtcFacade.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 28.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    The interface of the class that allows you to work with Bitcoin sidechain part of blockchain.
 */
public protocol BtcFacade {
    
/**
     Create address in Bitcoin network
     
     - Parameter nameOrId: Name or id
     - Parameter wif: Sender wif from account
     - Parameter backupAddress: Bitcoin address to possibility of a refund
     - Parameter assetForFee: Id of asset which is pay fee
     - Parameter completion: Callback in which the information will return whether the transaction was successful.
     - Parameter noticeHandler: Callback in which the information will return whether the transaction was confirmed.
     
     - Remark:
     Default asset is **"1.3.0"**
 */
    func generateBtcAddress(nameOrId: String,
                            wif: String,
                            backupAddress: String,
                            assetForFee: String?,
                            completion: @escaping Completion<Bool>,
                            noticeHandler: NoticeHandler?)
    
/**
    Send BTC to Bitcoin network to Bitcoin address
    
    - Parameter nameOrId: Name or id
    - Parameter wif: Sender wif from account
    - Parameter toBtcAddress: Receiver bitcoin address
    - Parameter amount: Amount
    - Parameter assetForFee: Id of asset which is pay fee    
    - Parameter completion: Callback in which the information will return whether the transaction was successful.
    - Parameter noticeHandler: Callback in which the information will return whether the transaction was confirmed.         
*/
   func withdrawBtc(nameOrId: String,
                    wif: String,
                    toBtcAddress: String,
                    amount: UInt,
                    assetForFee: String?,
                    completion: @escaping Completion<Bool>,
                    noticeHandler: NoticeHandler?)
    
/**
     Get created Bitcoin addresses
 
     - Parameter nameOrId: Name or id
     - Parameter completion: Callback in which the information will return [BtcAddress](BtcAddress) object (if it was created) or error
 */
    func getBtcAddress(nameOrId: String,
                       completion: @escaping Completion<BtcAddress?>)
    
/**
     Returns all approved deposits, for the given account id or name.
 
     - Parameter nameOrId: Name or id
     - Parameter completion: Callback in which return Deposits objects or error.
 */
    func getBtcAccountDeposits(nameOrId: String,
                               completion: @escaping Completion<[BtcDeposit]>)
        
/**
     Returns all approved withdrawals, for the given account id or name.
     
     - Parameter nameOrId: Name or id
     - Parameter completion: Callback in which return Withdrawals objects or error.
 */
    func getBtcAccountWithdrawals(nameOrId: String,
                                  completion: @escaping Completion<[BtcWithdrawal]>)
}
