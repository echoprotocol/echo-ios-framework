//
//  SidechainERC20IssueOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 02.12.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the
    [OperationType.sidechainERC20IssueOperation](OperationType.sidechainERC20IssueOperation)
 */
public struct SidechainERC20IssueOperation: BaseOperation {
    
    enum SidechainERC20IssueOperationCodingKeys: String, CodingKey {
        case depositId = "deposit"
        case account
        case token = "token"
        case amount
        case extensions
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var depositId: String
    public var account: Account
    public var token: ERC20Token
    public let amount: String
    public var deposit: ERC20Deposit?
    
    public init(from decoder: Decoder) throws {
        
        type = .sidechainERC20IssueOperation
        
        let values = try decoder.container(keyedBy: SidechainERC20IssueOperationCodingKeys.self)
        
        depositId = try values.decode(String.self, forKey: .depositId)
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)

        let tokenId = try values.decode(String.self, forKey: .token)
        token = ERC20Token(id: tokenId)
        
        amount = try values.decode(String.self, forKey: .amount)
        
        fee = AssetAmount(amount: 0, asset: Asset(Settings.defaultAsset))
    }
    
    mutating func changeToken(token: ERC20Token?) {
        
        if let token = token { self.token = token }
    }
    
    mutating func changeAccount(account: Account?) {
        
        if let account = account { self.account = account }
    }
    
    mutating func changeAssets(feeAsset: Asset?) {
        
        if let feeAsset = feeAsset { self.fee = AssetAmount(amount: fee.amount, asset: feeAsset) }
    }
    
    // MARK: ECHOCodable
    // Virtual operation
    
    public func toData() -> Data? {
        
        return nil
    }
    
    public func toJSON() -> Any? {
        
        return nil
    }
}

