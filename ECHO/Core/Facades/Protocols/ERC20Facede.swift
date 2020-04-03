//
//  ERC20Facede.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 29.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    The interface of the class that allows you to work with erc20 sidechain part of blockchain.
 */
public protocol ERC20Facade {
    
/**
    Register the Ethereum token on the Echo network
    
    - Parameter nameOrId: Sender name or id
    - Parameter wif: Sender wif from account
    - Parameter tokenAddress: Token address in Ethereum network
    - Parameter tokenName: Token name in Ethereum network
    - Parameter tokenSymbol: Token symbol in Ethereum network
    - Parameter tokenDecimals: Token decimals in Ethereum network
    - Parameter assetForFee: Id of asset which is pay fee
    - Parameter completion: Callback in which the information will return whether the transaction was successful.
    - Parameter noticeHandler: Callback in which the information will return whether the transaction was confirmed.
    
    - Remark:
    Default asset is **"1.3.0"**
*/
    func registerERC20Token(nameOrId: String,
                            wif: String,
                            tokenAddress: String,
                            tokenName: String,
                            tokenSymbol: String,
                            tokenDecimals: UInt8,
                            assetForFee: String?,
                            completion: @escaping Completion<Bool>,
                            noticeHandler: NoticeHandler?)
/**
    Returns information about erc20 token by token address, if exist.
    
    - Parameter tokenAddress: Token address in Ethereum network
    - Parameter completion: Callback in which return ERC20Token if exist object or error.
*/
    func getERC20Token(tokenAddress: String,
                       completion: @escaping Completion<ERC20Token?>)
    
/**
    Returns information about erc20 token by token id, if exist.
    
    - Parameter tokenId: Token id in Echo network
    - Parameter completion: Callback in which return ERC20Token if exist object or error.
*/
    func getERC20Token(tokenId: String,
                       completion: @escaping Completion<ERC20Token?>)
    
/**
    Return true if the contract exists and is ERC20 token contract registered.
    
    - Parameter tokenAddress: Contract identifier in Ethereum network
    - Parameter completion: Callback in which return true if the contract exists and is ERC20 token contract registered.
*/
    func checkERC20Token(contractId: String,
                         completion: @escaping Completion<Bool>)
    
/**
    Send ERC20 token to Ethereum network to ethAddress
    
    - Parameter nameOrId: Name or id
    - Parameter wif: Sender wif from account
    - Parameter toEthAddress: Receiver eth address
    - Parameter tokenId: Echo token id for withdraw
    - Parameter value: Amount
    - Parameter assetForFee:Id of asset which is pay fee
    - Parameter completion: Callback in which the information will return whether the transaction was successful.
    - Parameter noticeHandler: Callback in which the information will return whether the transaction was confirmed.
*/
   func withdrawERC20(nameOrId: String,
                      wif: String,
                      toEthAddress: String,
                      tokenId: String,
                      value: String,
                      assetForFee: String?,
                      completion: @escaping Completion<Bool>,
                      noticeHandler: NoticeHandler?)
    
/**
    Returns all ERC20 deposits, for the given account id.
    
    - Parameter nameOrId: Accoint name or id
    - Parameter completion: Callback in which return ERC20Deposit objects or error.
*/
   func getERC20AccountDeposits(nameOrId: String,
                                completion: @escaping Completion<[ERC20Deposit]>)
    
/**
    Returns all ERC20 withdrawals, for the given account id.
    
    - Parameter nameOrId: Accoint name or id
    - Parameter completion: Callback in which return ERC20Withdrawal objects or error.
*/
   func getERC20AccountWithdrawals(nameOrId: String,
                                   completion: @escaping Completion<[ERC20Withdrawal]>)
}
