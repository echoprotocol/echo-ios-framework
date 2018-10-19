//
//  AccountUpdateOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 22.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the [OperationType.accountUpdateOperation](OperationType.accountUpdateOperation)
 */
public struct AccountUpdateOperation: BaseOperation {
    
    enum AccountUpdateOperationCodingKeys: String, CodingKey {
        case account
        case owner
        case active
        case newOptions = "new_options"
        case extensions
        case fee
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var account: Account
    public let owner: OptionalValue<Authority>
    public let active: OptionalValue<Authority>
    public let newOptions: OptionalValue<AccountOptions>
    
    public init(account: Account, owner: Authority?, active: Authority?, options: AccountOptions?, fee: AssetAmount) {
        
        type = .accountUpdateOperation
        
        self.account = account
        self.owner = OptionalValue<Authority>(owner)
        self.active = OptionalValue<Authority>(active)
        self.newOptions = OptionalValue<AccountOptions>(options)
        
        self.fee = fee
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .accountUpdateOperation
        
        let values = try decoder.container(keyedBy: AccountUpdateOperationCodingKeys.self)
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        
        let ownerValue = try values.decode(Authority.self, forKey: .owner)
        let activeValue = try values.decode(Authority.self, forKey: .active)
        let newOptionsValue = try values.decode(AccountOptions.self, forKey: .newOptions)
        
        owner = OptionalValue(ownerValue)
        active = OptionalValue(activeValue)
        newOptions = OptionalValue(newOptionsValue)
        
        fee = try values.decode(AssetAmount.self, forKey: .fee)
    }
    
    mutating func changeAccount(_ account: Account?) {
        
        if let account = account { self.account = account }
    }
    
    // MARK: ECHOCodable
    
    public func toData() -> Data? {
        
        var data = Data()
        data.append(optional: fee.toData())
        data.append(optional: account.toData())
        data.append(optional: owner.toData())
        data.append(optional: active.toData())
        data.append(optional: newOptions.toData())
        data.append(optional: extensions.toData())
        return data
    }
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        var dictionary: [AnyHashable: Any?] = [AccountUpdateOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               AccountUpdateOperationCodingKeys.account.rawValue: account.toJSON(),
                                               AccountUpdateOperationCodingKeys.extensions.rawValue: extensions.toJSON()]
        
        if owner.isSet() {
            dictionary[AccountUpdateOperationCodingKeys.owner.rawValue] = owner.toJSON()
        }
        
        if active.isSet() {
            dictionary[AccountUpdateOperationCodingKeys.active.rawValue] = active.toJSON()
        }
        
        if newOptions.isSet() {
            dictionary[AccountUpdateOperationCodingKeys.newOptions.rawValue] = newOptions.toJSON()
        }
        
        array.append(dictionary)
        
        return array
    }
    
    mutating func changeAssets(feeAsset: Asset?) {
        
        if let feeAsset = feeAsset { self.fee = AssetAmount(amount: fee.amount, asset: feeAsset) }
    }
}
