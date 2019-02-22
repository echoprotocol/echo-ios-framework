//
//  ContractsFacade.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 10.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/// Typealias for function with notice
public typealias NoticeHandler = (_ notice: ECHONotification) -> Void

/**
    Encapsulates logic, associated with various blockchain smart contract processes
 */
public protocol ContractsFacade {
    
/**
     Creates contract on blockchain
     
     - Parameter registrarNameOrId: Name or id of account that creates the contract
     - Parameter passwordOrWif: Password or WIF from account for transaction signature
     - Parameter assetId: Asset of contract
     - Parameter byteCode: Bytecode of the created contract
     - Parameter supportedAssetId: If you dont want to link the contract with the specified asset
     - Parameter ethAccuracy: If true all balances passing to contract with ethereum accuracy
     - Parameter parameters: Parameters of constructor
     - Parameter completion: Callback which returns an [Bool](Bool) result of creation or error
 */
    func createContract(registrarNameOrId: String,
                        passwordOrWif: PassOrWif,
                        assetId: String,
                        assetForFee: String?,
                        byteCode: String,
                        supportedAssetId: String?,
                        ethAccuracy: Bool,
                        parameters: [AbiTypeValueInputModel]?,
                        completion: @escaping Completion<Bool>,
                        noticeHandler: NoticeHandler?)
    
/**
     Calls to contract on blockchain
     
     - Parameter registrarNameOrId: Name or id of account that call the contract
     - Parameter passwordOrWif: Password or WIF from account for transaction signature
     - Parameter assetId: Asset of contract
     - Parameter amount: Amount
     - Parameter contratId: Id of called contract
     - Parameter methodName: Name of called method
     - Parameter methodParams: Parameters of called method
     - Parameter completion: Callback which returns an [Bool](Bool) result of call or error
 */
    func callContract(registrarNameOrId: String,
                      passwordOrWif: PassOrWif,
                      assetId: String,
                      amount: UInt?,
                      assetForFee: String?,
                      contratId: String,
                      methodName: String,
                      methodParams: [AbiTypeValueInputModel],
                      completion: @escaping Completion<Bool>,
                      noticeHandler: NoticeHandler?)
    
/**
     Calls contract method without changing state of blockchain
     
     - Parameter registrarNameOrId: Name or id of account that call the contract
     - Parameter assetId: Asset of contract
     - Parameter contratId: Id of called contract
     - Parameter methodName: Name of called method
     - Parameter methodParams: Parameters of called method
     - Parameter completion: Callback which returns an [Bool](Bool) result of call or error
 */
    func queryContract(registrarNameOrId: String,
                       assetId: String,
                       contratId: String,
                       methodName: String,
                       methodParams: [AbiTypeValueInputModel],
                       completion: @escaping Completion<String>)
    
/**
     Return result of contract operation call
     
     - Parameter contractResultId: Contract result identifier
     - Parameter completion: Callback which returns an [ContractResultEnum](ContractResultEnum) or error
 */
    func getContractResult(contractResultId: String, completion: @escaping Completion<ContractResultEnum>)
    
/**
     Return list of contract logs
     
     - Parameter contractId: Contract id for fetching logs
     - Parameter fromBlockId: Number of the earliest block to retrieve
     - Parameter toBlockId: Number of the most recent block to retrieve
     - Parameter completion: Callback which returns an array of [ContractLog](ContractLog) result of call or error
 */
    func getContractLogs(contractId: String, fromBlock: Int, toBlock: Int, completion: @escaping Completion<[ContractLog]>)
    
/**
     Returns contracts called by identifiers
     
     - Parameter contractIds: Contracts identifiers for call
     - Parameter completion: Callback which returns an [[ContractInfo](ContractInfo)] or error
 */
    func getContracts(contractIds: [String], completion: @escaping Completion<[ContractInfo]>)
    
/**
     Returns all existing contracts from blockchain
     
     - Parameter completion: Callback which returns an [[ContractInfo](ContractInfo)] or error
 */
    func getAllContracts(completion: @escaping Completion<[ContractInfo]>)
    
/**
     Return full information about contract
     
     - Parameter contractId: Identifier for contract
     - Parameter completion: Callback which returns an [ContractStructEnum](ContractStructEnum) or error
 */
    func getContract(contractId: String, completion: @escaping Completion<ContractStructEnum>)
}
