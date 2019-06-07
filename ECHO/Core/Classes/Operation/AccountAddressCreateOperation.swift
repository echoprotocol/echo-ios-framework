//
//  AccountAddressCreateOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 20/05/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the [OperationType.generateEthAddressOperation](OperationType.generateEthAddressOperation)
 */
public struct GenerateEthAddressOperation: BaseOperation {
    
    enum AccountAddressCreateOperationCodingKeys: String, CodingKey {
        case account = "account"
        case extensions
        case fee
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var account: Account
    
    init(account: Account, fee: AssetAmount) {
        
        type = .generateEthAddressOperation
        
        self.account = account
        self.fee = fee
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .generateEthAddressOperation
        
        let values = try decoder.container(keyedBy: AccountAddressCreateOperationCodingKeys.self)
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
    }
    
    mutating func changeAccount(account: Account?) {
        
        if let account = account { self.account = account }
    }
    
    mutating func changeAssets(feeAsset: Asset?) {
        
        if let feeAsset = feeAsset { self.fee = AssetAmount(amount: fee.amount, asset: feeAsset) }
    }
    
    // MARK: ECHOCodable
    
    public func toData() -> Data? {
        
        var data = Data()
        data.append(optional: fee.toData())
        data.append(optional: account.toData())
        
        data.append(optional: extensions.toData())
        return data
    }
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        let dictionary: [AnyHashable: Any?] = [AccountAddressCreateOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               AccountAddressCreateOperationCodingKeys.account.rawValue: account.toJSON(),
                                               AccountAddressCreateOperationCodingKeys.extensions.rawValue: extensions.toJSON()]
        
        array.append(dictionary)
        
        return array
    }
}
