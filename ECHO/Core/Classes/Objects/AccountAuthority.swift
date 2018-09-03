//
//  AccountAuthority.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 20.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Class used to represent the weighted set of keys and accounts that must approve operations.

    [Authority details](https://dev-doc.myecho.app/structgraphene_1_1chain_1_1authority.html)
 */
public struct AccountAuthority: ECHOCodable, Decodable {
    
    public let account: Account
    public let value: Int
    
    public init(from decoder: Decoder) throws {
        
        var aValue = 0
        var aAccount = Account(String())
        
        let value = try decoder.singleValueContainer()
        let decodedValue = try value.decode([IntOrString].self)
        
        for intOrString in decodedValue {
            switch intOrString {
            case let .integer(intValue):
                aValue = intValue
            case let .string(stringValue):
                aAccount = Account(stringValue)
            }
        }
        
        self.value = aValue
        self.account = aAccount
    }
    
    // MARK: ECHOCodable
    
    func toJSON() -> Any? {
        
        let array: [Any?] = [account.toJSON(), value]
        return array
    }
    
    func toData() -> Data? {
        
        var data = Data()
        data.append(optional: account.toData())
        data.append(optional: Data.fromInt16(value))
        return data
    }
}
