//
//  Data+Extension.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 17.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

extension Data {
    
    mutating func append(optional other: Data?) {
        
        guard let data = other else { return }
        
        append(data)
    }
    
    init<T>(from value: T) {
        
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: MemoryLayout.size(ofValue: value)))
    }
    
    static func fromUIntLikeUnsignedByteArray(_ input: UInt) -> Data {
        
        var data = Data()
        var value = input
        
        while (value & 0xFFFFFFFFFFFFFF80) != 0 {
            let changed = (UInt8(value) & 0x7F) | 0x80
            data.append(changed)
            
            value >>= 7
        }
        
        let last = (UInt8(value) & 0x7F)
        data.append(last)
        
        return data
    }
    
    static func fromInt8(_ input: Int) -> Data {
        
        let value = Int8(clamping: input)
        var data = Data(from: value)
        data.reverse()
        return data
    }
    
    static func fromInt16(_ input: Int) -> Data {
        
        let value = Int16(clamping: input)
        var data = Data(from: value)
        data.reverse()
        return data
    }
    
    static func fromInt32(_ input: Int) -> Data {
        
        let value = Int32(clamping: input)
        var data = Data(from: value)
        data.reverse()
        return data
    }
    
    static func fromInt64(_ input: Int) -> Data {
        
        let value = Int64(clamping: input)
        var data = Data(from: value)
        data.reverse()
        return data
    }
    
    static func fromInt64(_ input: UInt) -> Data {
        
        let value = Int64(clamping: input)
        var data = Data(from: value)
        data.reverse()
        return data
    }
    
    static func fromBool(_ input: Bool) -> Data {
        
        let intValue = input ? 1 : 0
        return Data.fromInt8(intValue)
    }
    
    static func fromArray<T>(_ input: [T], elementToData: (T) -> (Data?)) -> Data {
        var data = Data()
        data.append(UInt8(clamping: input.count))
        
        for element in input {
            let elementData = elementToData(element)
            data.append(optional: elementData)
        }
        
        return data
    }
    
    static func fromSet<T>(_ input: Set<T>, elementToData: (T) -> (Data?)) -> Data {
        var data = Data()
        data.append(UInt8(clamping: input.count))
        
        for element in input {
            let elementData = elementToData(element)
            data.append(optional: elementData)
        }
        
        return data
    }
    
    static func fromString(_ input: String?) -> Data? {
        
        guard let input = input else {
            return Data(count: 1)
        }
        
        var data = Data()
        data.append(UInt8(clamping: input.count))
        data.append(optional: input.data(using: .utf8))
        return data
    }
}
