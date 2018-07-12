//
//  SocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

enum SocketOperationType: String {
    case call
}

enum SocketOperationKeys: String {
    case blockData = "get_dynamic_global_properties"
    case fullAccount = "get_full_accounts"
    case accountHistory = "get_account_history"
    case assets = "get_assets"
    case block = "get_block"
    case chainId = "get_chain_id"
    case contractResult = "get_contract_result"
    case object = "get_objects"
    case keyReference = "get_key_references"
    case requiredFee = "get_required_fees"
    case subscribeCallback = "set_subscribe_callback"
    case transaction = "broadcast_transaction_with_callback"
}

typealias OperationResult<T> = (operation: SocketOperation, result: Result<T, ECHOError>)

protocol SocketOperation: JSONCodable {
    
    var method: SocketOperationType { get }
    var operationId: Int { get }
    var apiId: Int { get }
    var completion: Completion<OperationResult<Any>> { get }
    func createParameters() -> [Any]
}

enum OperationCodingKeys: String, CodingKey {
    case method
    case params
    case id
}

extension SocketOperation {

    func toJSON() -> Any? {

        let dictionary: [AnyHashable: Any] = [OperationCodingKeys.method: method.rawValue,
                                              OperationCodingKeys.id: operationId,
                                              OperationCodingKeys.params: createParameters()]

        return dictionary
    }

    func toJSON() -> String? {

        let json: Any? = toJSON()
        let jsonString = (json as?  [AnyHashable: Any])
            .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: [])}
            .flatMap { String(data: $0, encoding: .utf8)}

        return jsonString ?? ""
    }
}
