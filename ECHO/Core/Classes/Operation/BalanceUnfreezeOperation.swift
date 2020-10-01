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
    
    public var account: Account
    public var amount: AssetAmount
    
    public init(from decoder: Decoder) throws {
        type = .balanceUnfreezeOperation
        let values = try decoder.container(keyedBy: BalanceUnfreezeOperationCodingKeys.self)
        fee = AssetAmount(amount: 0, asset: Asset(Settings.defaultAsset))
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        
        amount = try values.decode(AssetAmount.self, forKey: .amount)
    }
    
    mutating func changeAccount(account: Account?) {
        if let account = account {
            self.account = account
        }
    }
    
    mutating func changeAssets(amountAsset: Asset?) {
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
