//
//  AccountCreateOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 17.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

/**
    Struct used to encapsulate operations related to the [OperationType.accountCreateOperation](OperationType.accountCreateOperation)
 */
public struct AccountCreateOperation: BaseOperation {
    
    enum AccountCreateOperationCodingKeys: String, CodingKey {
        case name
        case registrar
        case referrer
        case referrerPercent = "referrer_percent"
        case owner
        case active
        case options
        case extensions
        case fee
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public let name: String
    public let registrar: String
    public let referrer: String
    public let referrerPercent: Int = 0
    public let owner: OptionalValue<Authority>
    public let active: OptionalValue<Authority>
    public let options: OptionalValue<AccountOptions>
    
    public init(from decoder: Decoder) throws {
        
        type = .accountCreateOperation
        
        let values = try decoder.container(keyedBy: AccountCreateOperationCodingKeys.self)
        
        name = try values.decode(String.self, forKey: .name)
        registrar = try values.decode(String.self, forKey: .registrar)
        referrer = try values.decode(String.self, forKey: .referrer)
        
        let ownerValue = try values.decode(Authority.self, forKey: .owner)
        let activeValue = try values.decode(Authority.self, forKey: .active)
        let optionsValue = try values.decode(AccountOptions.self, forKey: .options)
        
        owner = OptionalValue(ownerValue)
        active = OptionalValue(activeValue)
        options = OptionalValue(optionsValue)
        
        fee = try values.decode(AssetAmount.self, forKey: .fee)
    }
    
    // MARK: ECHOCodable
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        var dictionary: [AnyHashable: Any?] = [AccountCreateOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               AccountCreateOperationCodingKeys.name.rawValue: name,
                                               AccountCreateOperationCodingKeys.registrar.rawValue: registrar,
                                               AccountCreateOperationCodingKeys.referrer.rawValue: referrer,
                                               AccountCreateOperationCodingKeys.referrerPercent.rawValue: referrerPercent,
                                               AccountCreateOperationCodingKeys.extensions.rawValue: extensions.toJSON()]
        
        if owner.isSet() {
            dictionary[AccountCreateOperationCodingKeys.owner.rawValue] = owner.toJSON()
        }
        
        if active.isSet() {
            dictionary[AccountCreateOperationCodingKeys.active.rawValue] = active.toJSON()
        }
        
        if options.isSet() {
            dictionary[AccountCreateOperationCodingKeys.options.rawValue] = options.toJSON()
        }
        
        return array
    }
    
    public func toData() -> Data? {
        
        var data = Data()
        data.append(optional: fee.toData())
        data.append(optional: Data.fromString(name))
        data.append(optional: Data.fromString(registrar))
        data.append(optional: Data.fromString(referrer))
        data.append(optional: Data.fromInt8(referrerPercent))
        data.append(optional: owner.toData())
        data.append(optional: active.toData())
        data.append(optional: options.toData())
        data.append(optional: extensions.toData())
        return data
    }
}
