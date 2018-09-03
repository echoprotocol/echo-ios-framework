//
//  Address.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 17.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Represents account model in Graphene blockchain
    [Address model details](https://dev-doc.myecho.app/classgraphene_1_1chain_1_1address.html)
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
