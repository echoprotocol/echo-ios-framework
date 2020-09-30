//
//  BalanceUnfreezeOperation.swift
//  ECHO
//
//  Created by Alexander Eskin on 9/30/20.
//  Copyright © 2020 PixelPlex. All rights reserved.
//

import Foundation

/**
   Struct used to encapsulate operations related to the
   [OperationType.balanceUnfreezeOperation](OperationType.balanceUnfreezeOperation)
*/
public struct BalanceUnfreezeOperation: BaseOperation {
    enum BalanceUnfreezeOperationCodingKeys: String, CodingKey {
        case account
        case amount
        case extensions
    }
    
    public var type: OperationType
    public var extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public let account: Account
    public let amount: AssetAmount
    
    public init(from decoder: Decoder) throws {
        type = .balanceUnfreezeOperation
        let values = try decoder.container(keyedBy: BalanceUnfreezeOperationCodingKeys.self)
        fee = AssetAmount(amount: 0, asset: Asset(Settings.defaultAsset))
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        
        amount = try values.decode(AssetAmount.self, forKey: .amount)
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
