//
//  BalanceFreezeOperation.swift
//  ECHO
//
//  Created by Alexander Eskin on 9/30/20.
//  Copyright © 2020 PixelPlex. All rights reserved.
//

import Foundation

public struct BalanceFreezeOperation: BaseOperation {
    enum BalanceFreezeOperationCodingKeys: String, CodingKey {
        case fee
        case account
        case amount
        case duration
        case extensions
    }
    
    public var type: OperationType
    public var extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public let account: Account
    public let amount: AssetAmount
    public let duration: UInt16
    
    public init(from decoder: Decoder) throws {
        type = .balanceFreezeOperation
        let values = try decoder.container(keyedBy: BalanceFreezeOperationCodingKeys.self)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        
        amount = try values.decode(AssetAmount.self, forKey: .amount)
        duration = try values.decode(UInt16.self, forKey: .duration)
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
