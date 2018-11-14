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
     - Parameter password: Password from account for transaction signature
     - Parameter assetId: Asset of contract
     - Parameter byteCode: Bytecode of the created contract
     - Parameter parameters: Parameters of constructor 
     - Parameter completion: Callback which returns an [Bool](Bool) result of creation or error
     */
    func createContract(registrarNameOrId: String,
                        password: String,
                        assetId: String,
                        byteCode: String,
                        parameters: [AbiTypeValueInputModel]?,
                        completion: @escaping Completion<Bool>)
    
/**
     Calls to contract on blockchain
     
     - Parameter registrarNameOrId: Name or id of account that call the contract
     - Parameter password: Password from account for transaction signature
     - Parameter assetId: Asset of contract
     - Parameter contratId: Id of called contract
     - Parameter methodName: Name of called method
     - Parameter methodParams: Parameters of called method
     - Parameter completion: Callback which returns an [Bool](Bool) result of call or error
 */
    func callContract(registrarNameOrId: String,
                      password: String,
                      assetId: String,
                      contratId: String,
                      methodName: String,
                      methodParams: [AbiTypeValueInputModel],
                      completion: @escaping Completion<Bool>)
    
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
     
     - Parameter historyId: History operation identifier
     - Parameter completion: Callback which returns an [ContractResult](ContractResult) or error
 */
    func getContractResult(historyId: String, completion: @escaping Completion<ContractResult>)
    
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
     - Parameter completion: Callback which returns an [ContractStruct](ContractStruct) or error
 */
    func getContract(contractId: String, completion: @escaping Completion<ContractStruct>)
}
