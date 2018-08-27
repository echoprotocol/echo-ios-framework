//
//  AccountUpdateOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 22.08.2018.
//

struct AccountUpdateOperation: BaseOperation {
    
    enum AccountUpdateOperationCodingKeys: String, CodingKey {
        case account
        case owner
        case active
        case newOptions = "new_options"
        case extensions
        case fee
    }
    
    let type: OperationType
    let extensions: Extensions = Extensions()
    
    var account: Account
    let owner: OptionalValue<Authority>
    let active: OptionalValue<Authority>
    let newOptions: OptionalValue<AccountOptions>
    let fee: AssetAmount
    
    init(from decoder: Decoder) throws {
        
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
    
    func toData() -> Data? {
        
        var data = Data()
        data.append(optional: fee.toData())
        data.append(optional: account.toData())
        data.append(optional: owner.toData())
        data.append(optional: active.toData())
        data.append(optional: newOptions.toData())
        data.append(optional: extensions.toData())
        return data
    }
    
    func toJSON() -> Any? {
        
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
        
        return array
    }
}
