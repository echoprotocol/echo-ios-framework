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
struct IssueAssetOperation: BaseOperation {
    
    enum IssueAssetOperationCodingKeys: String, CodingKey {
        case issuer
        case assetToIssue = "asset_to_issue"
        case issueToAccount = "issue_to_account"
        case memo
        case extensions
        case fee
    }
    
    let type: OperationType
    let extensions: Extensions = Extensions()
    var fee: AssetAmount
    
    var issuer: Account
    let assetToIssue: AssetAmount
    var issueToAccount: Account
    var memo: Memo = Memo()
    
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
    
    init(from decoder: Decoder) throws {
        
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
    
    func toData() -> Data? {
        
        var data = Data()
        data.append(optional: fee.toData())
        data.append(optional: issuer.toData())
        data.append(optional: assetToIssue.toData())
        data.append(optional: issueToAccount.toData())
        data.append(optional: memo.toData())
        data.append(optional: extensions.toData())
        return data
    }
    
    func toJSON() -> Any? {
        
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
}
