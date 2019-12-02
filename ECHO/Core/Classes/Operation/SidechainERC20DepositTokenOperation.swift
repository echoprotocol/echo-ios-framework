//
//  SidechainERC20DepositTokenOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 02.12.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the
    [OperationType.sidechainERC20DepositTokenOperation](OperationType.sidechainERC20DepositTokenOperation)
 */
public struct SidechainERC20DepositTokenOperation: BaseOperation {
    
    enum SidechainERC20DepositTokenOperationCodingKeys: String, CodingKey {
        case committeeMember = "committee_member_id"
        case maliciousCommitteemen = "malicious_committeemen"
        case account
        case tokenAddress = "erc20_token_addr"
        case value
        case transactionHash = "transaction_hash"
        case extensions
        case fee
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var committeeMember: Account
    public let maliciousCommitteemen: [String]
    public var account: Account
    public let tokenAddress: String
    public let value: String
    public let transactionHash: String
    
    public init(from decoder: Decoder) throws {
        
        type = .sidechainERC20DepositTokenOperation
        
        let values = try decoder.container(keyedBy: SidechainERC20DepositTokenOperationCodingKeys.self)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
        maliciousCommitteemen = try values.decode([String].self, forKey: .maliciousCommitteemen)
        tokenAddress = try values.decode(String.self, forKey: .tokenAddress)
        value = try values.decode(String.self, forKey: .value)
        transactionHash = try values.decode(String.self, forKey: .transactionHash)
        
        
        let committeeMemberId = try values.decode(String.self, forKey: .committeeMember)
        committeeMember = Account(committeeMemberId)
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        
    }
    
    mutating func changeAccounts(account: Account?, committeeMember: Account?) {
        
        if let account = account { self.account = account }
        if let committeeMember = committeeMember { self.committeeMember = committeeMember }
    }
    
    mutating func changeAssets(feeAsset: Asset?) {
        
        if let feeAsset = feeAsset { self.fee = AssetAmount(amount: fee.amount, asset: feeAsset) }
    }
    
    // MARK: ECHOCodable
    // Not used in library and called by committee_member
    
    public func toData() -> Data? {
        
        return nil
    }
    
    public func toJSON() -> Any? {
        
        return nil
    }
}

