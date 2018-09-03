//
//  Address.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 17.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public struct Address: ECHOCodable {
    
    public var data: Data?
    public var hash: UInt?
    public var addressString: String
    
    public init(_ address: String, data: Data?) {
        self.addressString = address
        self.data = data
    }
    
    // MARK: ECHOCodable
    
    func toData() -> Data? {
        return data
    }
    
    func toJSON() -> Any? {
        return addressString
    }
    
    func toJSON() -> String? {
        return addressString
    }
}
