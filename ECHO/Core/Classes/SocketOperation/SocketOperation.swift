//
//  SocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Method type for call to blockchain
 */
public enum SocketOperationType: String {
    case call
    case notice
}

/**
    Represents blockchain operations by keys
 */
enum SocketOperationKeys: String {
    case blockData = "get_dynamic_global_properties"
    case fullAccount = "get_full_accounts"
    case accountHistory = "get_account_history"
    case assets = "get_assets"
    case block = "get_block"
    case chainId = "get_chain_id"
    case contractResult = "get_contract_result"
    case object = "get_objects"
    case requiredFee = "get_required_fees"
    case subscribeCallback = "set_subscribe_callback"
    case setBlockAppliedCallback = "set_block_applied_callback"
    case transaction = "broadcast_transaction"
    case transactionWithCallBack = "broadcast_transaction_with_callback"
    case listAssets = "list_assets"
    case getContracts = "get_contracts"
    case getContract = "get_contract"
    case callContractNoChangingState = "call_contract_no_changing_state"
    case getContractLogs = "get_contract_logs"
    case subscribeContractLogs = "subscribe_contract_logs"
    case registerAccount = "register_account"
    case getKeyReferences = "get_key_references"
    case getGlobalProperties = "get_global_properties"
    case getSidechainTransfers = "get_sidechain_transfers"
    case subscribeContracts = "subscribe_contracts"
    case getEthAddress = "get_eth_address"
}

typealias OperationResult<T> = (operation: SocketOperation, result: Result<T, ECHOError>)

/**
    Represents blockchain call [Source](http://docs.bitshares.org/api/rpc.html)
 */
public protocol SocketOperation: JSONCodable {
    
    var method: SocketOperationType { get }
    var operationId: Int { get }
    var apiId: Int { get }
    func createParameters() -> [Any]
    func handleResponse(_ response: ECHODirectResponse)
    func forceEnd()
}

/**
    Represents custom blockchain call with customized methods
 */
public protocol CustomSocketOperation: SocketOperation {
    
    func setOperationId(_ operationId: Int)
    func setApiId(_ apiId: Int)
}

/**
    Keys for json creation of blockchain call
 */
public enum OperationCodingKeys: String, CodingKey {
    case method
    case params
    case id
}

public extension SocketOperation {

    func toJSON() -> Any? {

        let dictionary: [AnyHashable: Any] = [OperationCodingKeys.method.rawValue: method.rawValue,
                                              OperationCodingKeys.id.rawValue: operationId,
                                              OperationCodingKeys.params.rawValue: createParameters()]

        return dictionary
    }
    
    func forceEnd() { }
}
