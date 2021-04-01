//
//  BalanceFreezeOperation.swift
//  ECHO
//
//  Created by Alexander Eskin on 9/30/20.
//  Copyright © 2020 PixelPlex. All rights reserved.
//

import Foundation

/**
   Struct used to encapsulate operations related to the
   [OperationType.balanceFreezeOperation](OperationType.balanceFreezeOperation)
*/
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
    
    public var account: Account
    public var amount: AssetAmount
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
    
    mutating func changeAccount(account: Account?) {
        if let account = account {
            self.account = account
        }
    }
    
    mutating func changeAssets(amountAsset: Asset?, feeAsset: Asset?) {
        if let feeAsset = feeAsset {
            fee = AssetAmount(amount: fee.amount, asset: feeAsset)
        }
        if let amountAsset = amountAsset {
            amount = AssetAmount(amount: amount.amount, asset: amountAsset)
        }
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
