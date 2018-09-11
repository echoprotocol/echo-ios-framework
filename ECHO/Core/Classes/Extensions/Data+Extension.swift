//
//  Data+Extension.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 17.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

/**
    Extension for [Data](Data)
 
    - Provide save append to data
    - Provide init from [UInt](UInt), [Int8](Int8), [Int16](Int16),
        [Int32](Int32), [Int64](Int64), [UInt64](UInt64),
        [Bool](Bool), [Array](Array),
        [Set](Set), [String](String)
 */
extension Data {
    
    mutating func append(optional other: Data?) {
        
        guard let data = other else { return }
        append(data)
    }
    
    init<T>(from value: T) {
        
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    static func fromUIntLikeUnsignedByteArray(_ input: UInt) -> Data {
        
        var data = Data()
        var input = input
        while (input & 0xFFFFFFFFFFFFFF80) != 0 {
            let changed = (UInt8(truncatingIfNeeded: input) & 0x7F) | 0x80
            data.append(changed)
            
            input >>= 7
        }
        
        let last = (UInt8(truncatingIfNeeded: input) & 0x7F)
        data.append(last)
        
        return data
    }
    
    static func fromInt8(_ input: Int) -> Data {
        
        return Data() + Int8(clamping: input).littleEndian
    }
    
    static func fromInt16(_ input: Int) -> Data {

        return Data() + Int16(clamping: input).littleEndian
    }
    
    static func fromInt32(_ input: Int) -> Data {

        return Data() + Int32(clamping: input).littleEndian
    }
    
    static func fromInt64(_ input: Int) -> Data {

        return Data() + Int64(clamping: input).littleEndian
    }
    
    static func fromUint64(_ input: UInt) -> Data {

        return Data() + UInt64(clamping: input).littleEndian
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
        data.append(UInt8(truncatingIfNeeded: input.count))
        data.append(optional: input.data(using: .utf8))
        return data
    }
}

/**
    Extension for [Data](Data)
 
    - Provide init from hex
    - Provide hex representation
 */
extension Data {
    
    init?(hex: String) {
        
        let len = hex.count / 2
        var data = Data(capacity: len)
        for indexI in 0..<len {
            let indexJ = hex.index(hex.startIndex, offsetBy: indexI * 2)
            let indexK = hex.index(indexJ, offsetBy: 2)
            let bytes = hex[indexJ..<indexK]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
    
    var hex: String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }
}
