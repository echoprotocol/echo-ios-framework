//
//  IssueAssetOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 22.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

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
    
    let issuer: Account
    let assetToIssue: AssetAmount
    let issueToAccount: Account
    let fee: AssetAmount
    var memo: Memo = Memo()
    
    init(from decoder: Decoder) throws {
        
        type = .assetIssueOperation
        
        let values = try decoder.container(keyedBy: IssueAssetOperationCodingKeys.self)
        
        issuer = try values.decode(Account.self, forKey: .issuer)
        assetToIssue = try values.decode(AssetAmount.self, forKey: .assetToIssue)
        issueToAccount = try values.decode(Account.self, forKey: .issueToAccount)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
        
        if values.contains(.memo) {
            memo = try values.decode(Memo.self, forKey: .memo)
        }
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
        
        return array
    }
}
