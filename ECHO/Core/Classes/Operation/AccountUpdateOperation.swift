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
        case active
        case newOptions = "new_options"
        case extensions
        case fee
        case edKey = "ed_key"
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var account: Account
    public let active: OptionalValue<Authority>
    public let newOptions: OptionalValue<AccountOptions>
    
    public var edKey: Address?
    
    public init(account: Account,
                active: Authority?,
                edKey: Address?,
                options: AccountOptions?,
                fee: AssetAmount) {
        
        type = .accountUpdateOperation
        
        self.account = account
        self.active = OptionalValue<Authority>(active)
        self.newOptions = OptionalValue<AccountOptions>(options)
        self.edKey = edKey
        
        self.fee = fee
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .accountUpdateOperation
        
        let values = try decoder.container(keyedBy: AccountUpdateOperationCodingKeys.self)
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        
        let activeValue = try values.decode(Authority.self, forKey: .active)
        let newOptionsValue = try values.decode(AccountOptions.self, forKey: .newOptions)
        
        active = OptionalValue(activeValue)
        newOptions = OptionalValue(newOptionsValue)
        
        fee = try values.decode(AssetAmount.self, forKey: .fee)
        if let edKeyString = try? values.decode(String.self, forKey: .edKey) {
            edKey = Address(edKeyString, data: nil)
        }
    }
    
    mutating func changeAccount(_ account: Account?) {
        
        if let account = account { self.account = account }
    }
    
    // MARK: ECHOCodable
    
    public func toData() -> Data? {
        
        var data = Data()
        data.append(optional: fee.toData())
        data.append(optional: account.toData())
        data.append(optional: active.toData())
        if let edKey = edKey {
            data.append(1)
            data.append(optional: edKey.toData())
        } else {
            data.append(0)
        }
        data.append(optional: newOptions.toData())
        data.append(optional: extensions.toData())
        
        print(data.hex)
        
        return data
    }
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        var dictionary: [AnyHashable: Any?] = [AccountUpdateOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               AccountUpdateOperationCodingKeys.account.rawValue: account.toJSON(),
                                               AccountUpdateOperationCodingKeys.edKey.rawValue: edKey?.toJSON(),
                                               AccountUpdateOperationCodingKeys.extensions.rawValue: extensions.toJSON()]
        
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
