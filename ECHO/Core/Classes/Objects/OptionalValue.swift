//
//  OptionalValue.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 20.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Container template class used whenever we have an optional field.

    The idea here is that the binary serialization of this field should be performed in a specific way
    determined by the field implementing the {@link ByteSerializable}
    interface, more specifically using the {@link ByteSerializable#toBytes()} method.

    However, if the field is missing, the Optional class should be able to know how to serialize it,
    as this is always done by placing an zero byte.

 */
public struct OptionalValue<T>: ECHOCodable where T: ECHOCodable {
    
    public let object: T?
    let addByteToStart: Bool
    
    public init(_ object: T?, addByteToStart: Bool = false) {
        self.object = object
        self.addByteToStart = addByteToStart
    }
    
    public func isSet() -> Bool {
        return object != nil
    }
    
    // MARK: ECHOCodable
    
    public func toJSON() -> Any? {
        return object?.toJSON()
    }
    
    public func toJSON() -> String? {
        return object?.toJSON()
    }
    
    public func toData() -> Data? {
        
        guard let object = object else {
            return Data(count: 1)
        }
        
        var data = Data()
        if addByteToStart {
            data.append(1)
        }
        data.append(optional: object.toData())
        return data
    }
}
