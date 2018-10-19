//
//  IssueAssetOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 22.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the [OperationType.assetIssueOperation](OperationType.assetIssueOperation)
 */
public struct IssueAssetOperation: BaseOperation {
    
    enum IssueAssetOperationCodingKeys: String, CodingKey {
        case issuer
        case assetToIssue = "asset_to_issue"
        case issueToAccount = "issue_to_account"
        case memo
        case extensions
        case fee
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var issuer: Account
    public var assetToIssue: AssetAmount
    public var issueToAccount: Account
    public var memo: Memo = Memo()
    
    init(issuer: Account, assetToIssue: AssetAmount, issueToAccount: Account, fee: AssetAmount, memo: Memo?) {
        
        type = .assetIssueOperation
        
        self.issuer = issuer
        self.assetToIssue = assetToIssue
        self.issueToAccount = issueToAccount
        self.fee = fee
        if let memo = memo {
            self.memo = memo
        }
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .assetIssueOperation
        
        let values = try decoder.container(keyedBy: IssueAssetOperationCodingKeys.self)
        
        let issuerId = try values.decode(String.self, forKey: .issuer)
        issuer = Account(issuerId)
        assetToIssue = try values.decode(AssetAmount.self, forKey: .assetToIssue)
        let issueToAccountId = try values.decode(String.self, forKey: .issueToAccount)
        issueToAccount = Account(issueToAccountId)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
        
        if values.contains(.memo) {
            memo = try values.decode(Memo.self, forKey: .memo)
        }
    }
    
    mutating func changeAccounts(issuer: Account?, issueToAccount: Account?) {
        
        if let issuer = issuer { self.issuer = issuer }
        if let issueToAccount = issueToAccount { self.issueToAccount = issueToAccount }
    }
    
    // MARK: ECHOCodable
    
    public func toData() -> Data? {
        
        var data = Data()
        data.append(optional: fee.toData())
        data.append(optional: issuer.toData())
        data.append(optional: assetToIssue.toData())
        data.append(optional: issueToAccount.toData())
        data.append(optional: memo.toData())
        data.append(optional: extensions.toData())
        return data
    }
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        var dictionary: [AnyHashable: Any?] = [IssueAssetOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               IssueAssetOperationCodingKeys.issuer.rawValue: issuer.toJSON(),
                                               IssueAssetOperationCodingKeys.assetToIssue.rawValue: assetToIssue.toJSON(),
                                               IssueAssetOperationCodingKeys.issueToAccount.rawValue: issueToAccount.toJSON(),
                                               IssueAssetOperationCodingKeys.extensions.rawValue: extensions.toJSON()]
        
        if memo.byteMessage != nil {
            dictionary[IssueAssetOperationCodingKeys.memo.rawValue] = memo.toJSON()
        }
        
        array.append(dictionary)
        
        return array
    }
    
    mutating func changeAssets(feeAsset: Asset?, assetToIssue: Asset?) {
        
        if let feeAsset = feeAsset { self.fee = AssetAmount(amount: fee.amount, asset: feeAsset) }
        if let assetToIssue = assetToIssue { self.assetToIssue = AssetAmount(amount: self.assetToIssue.amount, asset: assetToIssue) }
    }
}
