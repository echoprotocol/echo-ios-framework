//
//  RequestBalanceUnfreezeOperation.swift
//  ECHO
//
//  Created by Alexander Eskin on 9/30/20.
//  Copyright © 2020 PixelPlex. All rights reserved.
//

import Foundation

/**
   Struct used to encapsulate operations related to the
   [OperationType.requestBalanceUnfreezeOperation](OperationType.requestBalanceUnfreezeOperation)
*/
public struct RequestBalanceUnfreezeOperation: BaseOperation {
    enum RequestBalanceUnfreezeOperationCodingKeys: String, CodingKey {
        case fee
        case account
        case objectsToUnfreeze = "objects_to_unfreeze"
        case extensions
    }
    
    public var type: OperationType
    public var extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public let account: Account!
    public let objectsToUnfreeze: [FrozenBalanceObject]
    
    public init(from decoder: Decoder) throws {
        type = .requestBalanceUnfreezeOperation
        let values = try decoder.container(keyedBy: RequestBalanceUnfreezeOperationCodingKeys.self)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
        
        let accountID = try values.decode(String.self, forKey: .account)
        account = Account(accountID)
        
        let objectsID = try values.decode([String].self, forKey: .objectsToUnfreeze)
        objectsToUnfreeze = objectsID.map { FrozenBalanceObject($0) }
    }
    
    // MARK: ECHOCodable
    // Not called by user
    
    public func toData() -> Data? {
        return nil
    }
    
    public func toJSON() -> Any? {
        return nil
    }
}
