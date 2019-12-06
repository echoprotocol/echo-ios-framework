//
//  SidechainERC20BurnOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 02.12.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the
    [OperationType.sidechainERC20BurnOperation](OperationType.sidechainERC20BurnOperation)
 */
public struct SidechainERC20BurnOperation: BaseOperation {
    
    enum SidechainERC20BurnOperationCodingKeys: String, CodingKey {
        case withdrawId = "withdraw"
        case account
        case token = "token"
        case amount
        case extensions
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var withdrawId: String
    public var account: Account
    public var token: ERC20Token
    public let amount: String
    public var withdraw: ERC20Withdrawal?
    
    public init(from decoder: Decoder) throws {
        
        type = .sidechainERC20BurnOperation
        
        let values = try decoder.container(keyedBy: SidechainERC20BurnOperationCodingKeys.self)
        
        withdrawId = try values.decode(String.self, forKey: .withdrawId)
        
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
