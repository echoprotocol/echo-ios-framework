//
//  ContractsFacade.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 10.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Encapsulates logic, associated with various blockchain smart contract processes
 */
public protocol ContractsFacade {
    
/**
     Creates contract on blockchain
     
     - Parameter registrarNameOrId: Name or id of account that creates the contract
     - Parameter wif: WIF from account for transaction signature
     - Parameter assetId: Asset of contract
     - Parameter byteCode: Bytecode of the contract
     - Parameter supportedAssetId: If you dont want to link the contract with the specified asset
     - Parameter ethAccuracy: If true all balances passing to contract with ethereum accuracy
     - Parameter parameters: Parameters of constructor
     - Parameter sendCompletion: Callback in which the information will return transaction ID or error
     - Parameter confirmNoticeHandler: Callback in which the information will return whether the transaction was confirmed or not.
 */
    func createContract(
        registrarNameOrId: String,
        wif: String,
        assetId: String,
        amount: UInt?,
        assetForFee: String?,
        byteCode: String,
        supportedAssetId: String?,
        ethAccuracy: Bool,
        parameters: [AbiTypeValueInputModel]?,
        sendCompletion: @escaping Completion<String>,
        confirmNoticeHandler: NoticeHandler?
    )
    
/**
     Creates contract on blockchain
     
     - Parameter registrarNameOrId: Name or id of account that creates the contract
     - Parameter wif: WIF from account for transaction signature
     - Parameter assetId: Asset of contract
     - Parameter byteCode: Full bytecode for contract creation
     - Parameter supportedAssetId: If you dont want to link the contract with the specified asset
     - Parameter ethAccuracy: If true all balances passing to contract with ethereum accuracy
     - Parameter sendCompletion: Callback in which the information will return transaction ID or error
     - Parameter confirmNoticeHandler: Callback in which the information will return whether the transaction was confirmed or not.
 */
    func createContract(
        registrarNameOrId: String,
        wif: String,
        assetId: String,
        amount: UInt?,
        assetForFee: String?,
        byteCode: String,
        supportedAssetId: String?,
        ethAccuracy: Bool,
        sendCompletion: @escaping Completion<String>,
        confirmNoticeHandler: NoticeHandler?
    )
    
/**
     Calls to contract on blockchain
     
     - Parameter registrarNameOrId: Name or id of account that call the contract
     - Parameter wif: WIF from account for transaction signature
     - Parameter assetId: Asset of contract
     - Parameter amount: Amount
     - Parameter contratId: Id of called contract
     - Parameter methodName: Name of called method
     - Parameter methodParams: Parameters of called method
     - Parameter sendCompletion: Callback in which the information will return transaction ID or error
     - Parameter confirmNoticeHandler: Callback in which the information will return whether the transaction was confirmed or not.
 */
    func callContract(
        registrarNameOrId: String,
        wif: String,
        assetId: String,
        amount: UInt?,
        assetForFee: String?,
        contratId: String,
        methodName: String,
        methodParams: [AbiTypeValueInputModel],
        sendCompletion: @escaping Completion<String>,
        confirmNoticeHandler: NoticeHandler?
    )
    
/**
     Calls to contract on blockchain
     
     - Parameter registrarNameOrId: Name or id of account that call the contract
     - Parameter wif: WIF from account for transaction signature
     - Parameter assetId: Asset of contract
     - Parameter amount: Amount
     - Parameter contratId: Id of called contract
     - Parameter byteCode: Code which will be execute
     - Parameter sendCompletion: Callback in which the information will return transaction ID or error
     - Parameter confirmNoticeHandler: Callback in which the information will return whether the transaction was confirmed or not.
 */
    func callContract(
        registrarNameOrId: String,
        wif: String,
        assetId: String,
        amount: UInt?,
        assetForFee: String?,
        contratId: String,
        byteCode: String,
        sendCompletion: @escaping Completion<String>,
        confirmNoticeHandler: NoticeHandler?
    )
    
/**
     Calls contract method without changing state of blockchain
     
     - Parameter registrarNameOrId: Name or id of account that call the contract
     - Parameter amount: Amount for call
     - Parameter assetId: Asset for call
     - Parameter contratId: Id of called contract
     - Parameter methodName: Name of called method
     - Parameter methodParams: Parameters of called method
     - Parameter completion: Callback which returns an [Bool](Bool) result of call or error
 */
    func queryContract(
        registrarNameOrId: String,
        amount: UInt,
        assetId: String,
        contratId: String,
        methodName: String,
        methodParams: [AbiTypeValueInputModel],
        completion: @escaping Completion<String>
    )
    
/**
     Calls contract method without changing state of blockchain
     
     - Parameter registrarNameOrId: Name or id of account that call the contract
     - Parameter amount: Amount for call
     - Parameter assetId: Asset for call
     - Parameter contratId: Id of called contract
     - Parameter byteCode: Code which will be execute
     - Parameter completion: Callback which returns an [Bool](Bool) result of call or error
 */
    func queryContract(
        registrarNameOrId: String,
        amount: UInt,
        assetId: String,
        contratId: String,
        byteCode: String,
        completion: @escaping Completion<String>
    )
    
/**
     Return result of contract operation call
     
     - Parameter contractResultId: Contract result identifier
     - Parameter completion: Callback which returns an [ContractResultEnum](ContractResultEnum) or error
 */
    func getContractResult(
        contractResultId: String,
        completion: @escaping Completion<ContractResultEnum>
    )
    
/**
     Return list of contract logs
     
     - Parameter contractId: Contract id for fetching logs
     - Parameter fromBlockId: Number of the earliest block to retrieve
     - Parameter toBlock: Number of the latest block to retrieve
     - Parameter completion: Callback which returns an array of [ContractLogEnum](ContractLogEnum) result of call or error
 */
    func getContractLogs(
        contractId: String,
        fromBlock: Int,
        toBlock: Int,
        completion: @escaping Completion<[ContractLogEnum]>
    )
    
/**
     Returns contracts called by identifiers
     
     - Parameter contractIds: Contracts identifiers for call
     - Parameter completion: Callback which returns an [[ContractInfo](ContractInfo)] or error
 */
    func getContracts(
        contractIds: [String],
        completion: @escaping Completion<[ContractInfo]>
    )
    
/**
     Return full information about contract
     
     - Parameter contractId: Identifier for contract
     - Parameter completion: Callback which returns an [ContractStructEnum](ContractStructEnum) or error
 */
    func getContract(
        contractId: String,
        completion: @escaping Completion<ContractStructEnum>
    )
}
