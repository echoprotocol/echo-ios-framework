//
//  SidechainIssueOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 11/06/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
   Struct used to encapsulate operations related to the
    [OperationType.sidechainIssueOperation](OperationType.sidechainIssueOperation)
*/
public struct SidechainIssueOperation: BaseOperation {
    
    enum SidechainIssueOperationCodingKeys: String, CodingKey {
        case account = "account"
        case depositId = "deposit_id"
        case value
        case fee
        case extensions
    }
    
    public var type: OperationType
    public var fee: AssetAmount
    public var value: AssetAmount
    public var account: Account
    public var depositId: String
    public var deposit: EthDeposit?
    
    public var extensions: Extensions = Extensions()
    
    init(account: Account, value: AssetAmount, depositId: String, fee: AssetAmount) {
        
        type = .sidechainIssueOperation
        
        self.account = account
        self.fee = fee
        self.value = value
        self.depositId = depositId
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .sidechainIssueOperation
        
        let values = try decoder.container(keyedBy: SidechainIssueOperationCodingKeys.self)
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        depositId = try values.decode(String.self, forKey: .depositId)
        value = try values.decode(AssetAmount.self, forKey: .value)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
    }
    
    mutating func changeAccount(account: Account?) {
        
        if let account = account { self.account = account }
    }
    
    mutating func changeAssets(valueAsset: Asset?, feeAsset: Asset?) {
        
        if let feeAsset = feeAsset { self.fee = AssetAmount(amount: fee.amount, asset: feeAsset) }
        if let valueAsset = valueAsset { self.value = AssetAmount(amount: value.amount, asset: valueAsset) }
    }
    
    // It is virtual operation
    public func toData() -> Data? {
        
        return nil
    }
    
    // It is virtual operation
    public func toJSON() -> Any? {
        
        return nil
    }
}
