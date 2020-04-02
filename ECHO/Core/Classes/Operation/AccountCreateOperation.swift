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
        case active
        case options
        case extensions
        case fee
        case edKey = "echorand_key"
        case evmAddress = "evm_address"
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public let name: String
    public var registrar: Account
    public let active: OptionalValue<Authority>
    public let options: OptionalValue<AccountOptions>
    public let edKey: Address
    public let evmAddress: String?
    
    public init(from decoder: Decoder) throws {
        
        type = .accountCreateOperation
        
        let values = try decoder.container(keyedBy: AccountCreateOperationCodingKeys.self)
        
        name = try values.decode(String.self, forKey: .name)
        
        let registrarId = try values.decode(String.self, forKey: .registrar)

        registrar = Account(registrarId)
        
        let activeValue = try values.decode(Authority.self, forKey: .active)
        let optionsValue = try values.decode(AccountOptions.self, forKey: .options)
        
        active = OptionalValue(activeValue)
        options = OptionalValue(optionsValue)
        
        fee = try values.decode(AssetAmount.self, forKey: .fee)
        let edKeyString = try values.decode(String.self, forKey: .edKey)
        edKey = Address(edKeyString, data: nil)
        
        evmAddress = try? values.decode(String.self, forKey: .evmAddress)
    }
    
    // MARK: ECHOCodable
    // Not used for send
    
    public func toJSON() -> Any? {
        return nil
    }
    
    public func toData() -> Data? {
        return nil
    }
    
    // MARK: Change
    
    mutating func changeAccounts(registrar: Account?) {
        if let registrar = registrar { self.registrar = registrar }
    }
    
    mutating func changeAssets(feeAsset: Asset?) {
        if let feeAsset = feeAsset { self.fee = AssetAmount(amount: fee.amount, asset: feeAsset) }
    }
}
