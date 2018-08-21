//
//  AccountAuthority.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 20.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

public struct AccountAuthority: ECHOCodable, Decodable {
    
    public var account: Account
    public var value: Int
    
    public init(from decoder: Decoder) throws {
        
        self.value = 0
        self.account = Account(String())
        
        let value = try decoder.singleValueContainer()
        let decodedValue = try value.decode([IntOrString].self)
        
        for intOrString in decodedValue {
            switch intOrString {
            case let .integer(intValue):
                self.value = intValue
            case let .string(stringValue):
                self.account = Account(stringValue)
            }
        }
    }
    
    // MARK: ECHOCodable
    
    func toJSON() -> String? {
        
        let json: Any? = toJSON()
        let jsonString = (json as?  [AnyHashable: Any?])
            .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: [])}
            .flatMap { String(data: $0, encoding: .utf8)}
        
        return jsonString
    }
    
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
