//
//  SidechainETHApproveAddressOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 03.12.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the
    [OperationType.sidechainETHApproveAddressOperation](OperationType.sidechainETHApproveAddressOperation)
 */
public struct SidechainETHApproveAddressOperation: BaseOperation {
    
    enum SidechainETHApproveAddressOperationCodingKeys: String, CodingKey {
        case committeeMember = "committee_member_id"
        case maliciousCommitteemen = "malicious_committeemen"
        case account = "account"
        case ethAddr = "eth_addr"
        case extensions
        case fee
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var committeeMember: Account
    public let maliciousCommitteemen: [String]
    public var account: Account
    public let ethAddr: String
    
    public init(from decoder: Decoder) throws {
        
        type = .sidechainETHApproveAddressOperation
        
        let values = try decoder.container(keyedBy: SidechainETHApproveAddressOperationCodingKeys.self)
        
        let committeeMemberId = try values.decode(String.self, forKey: .committeeMember)
        committeeMember = Account(committeeMemberId)
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        
        maliciousCommitteemen = try values.decode([String].self, forKey: .maliciousCommitteemen)
        ethAddr = try values.decode(String.self, forKey: .ethAddr)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
    }
    
    mutating func changeAccounts(committeeMember: Account?, account: Account?) {
        
        if let account = account { self.account = account }
        if let committeeMember = committeeMember { self.committeeMember = committeeMember }
    }
    
    mutating func changeAssets(feeAsset: Asset?) {
        
        if let feeAsset = feeAsset { self.fee = AssetAmount(amount: fee.amount, asset: feeAsset) }
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
