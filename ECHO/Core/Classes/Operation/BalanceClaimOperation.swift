//
//  BalanceClaimOperation.swift
//  ECHO
//
//  Created by Alexander Eskin on 9/30/20.
//  Copyright © 2020 PixelPlex. All rights reserved.
//

import Foundation

public struct BalanceClaimOperation: BaseOperation {
    enum BalanceClaimOperationCodingKeys: String, CodingKey {
        case fee
        case depositToAccount = "deposit_to_account"
        case balanceToClaim = "balance_to_claim"
        case balanceOwnerKey = "balance_owner_key"
        case totalClaimed = "total_claimed"
        case extensions
        
    }
    
    public var type: OperationType
    public var extensions: Extensions = Extensions()
    public var fee: AssetAmount
     
    public let depositToAccount: Account
    public let balanceToClaim: BalanceObject
    public let balanceOwnerKey: Address
    public let totalClaimed: AssetAmount
    
    public init(from decoder: Decoder) throws {
        type = .balanceClaimOperation
        let values = try decoder.container(keyedBy: BalanceClaimOperationCodingKeys.self)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
        
        let accountId = try values.decode(String.self, forKey: .depositToAccount)
        depositToAccount = Account(accountId)
        
        let balanceId = try values.decode(String.self, forKey: .balanceToClaim)
        balanceToClaim = BalanceObject(balanceId)
        
        let balanceOwnerAddress = try values.decode(String.self, forKey: .balanceOwnerKey)
        balanceOwnerKey = Address(balanceOwnerAddress, data: nil)
        
        totalClaimed = try values.decode(AssetAmount.self, forKey: .totalClaimed)
    }
    
    // MARK: ECHOCodable
    // Not called by user
    
    public func toJSON() -> Any? {
        return nil
    }
    
    public func toData() -> Data? {
        return nil
    }
}
