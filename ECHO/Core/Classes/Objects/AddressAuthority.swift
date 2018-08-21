//
//  AddressAuthority.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 20.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

public struct AddressAuthority: ECHOCodable, Decodable {
    
    public var address: Address
    public var value: Int
    
    public init(from decoder: Decoder) throws {
        
        self.value = 0
        self.address = Address(String())
        
        let value = try decoder.singleValueContainer()
        let decodedValue = try value.decode([IntOrString].self)
        
        for intOrString in decodedValue {
            switch intOrString {
            case let .integer(intValue):
                self.value = intValue
            case let .string(stringValue):
                self.address = Address(stringValue)
            }
        }
    }
    
    // MARK: ECHOCodable
    
    func toJSON() -> Any? {
        
        let array: [Any?] = [address.toJSON(), value]
        return array
    }
    
    func toData() -> Data? {
        
        var data = Data()
        data.append(optional: address.toData())
        data.append(optional: Data.fromInt16(value))
        return data
    }
}
