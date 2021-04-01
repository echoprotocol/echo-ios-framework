//
//  Address.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 17.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Represents account model in Graphene blockchain
 
    [Address model documentations](https://dev-doc.myecho.app/classgraphene_1_1chain_1_1address.html)
 */
public struct Address: ECHOCodable {
    
    public var data: Data?
    public var hash: UInt?
    public var addressString: String
    
    public init(_ address: String, data: Data?) {
        self.addressString = address
        self.data = data
    }
    
    // MARK: ECHOCodable
    
    public func toData() -> Data? {
        return data
    }
    
    public func toJSON() -> Any? {
        return addressString
    }
    
    public func toJSON() -> String? {
        return addressString
    }
}
