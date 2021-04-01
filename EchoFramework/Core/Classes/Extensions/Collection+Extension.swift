//
//  Collection+Extension.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Extension for [Collection](Collection)
 
    - Provide save acces for element at index
 */
extension Collection {
    
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Array {
    public init(reserveCapacity: Int) {
        self = Array<Element>()
        self.reserveCapacity(reserveCapacity)
    }
    
    var slice: ArraySlice<Element> {
        return self[self.startIndex ..< self.endIndex]
    }
}

extension Collection where Self.Element == UInt8, Self.Index == Int {
    // Big endian order
    func toUInt32Array() -> Array<UInt32> {
        if isEmpty {
            return []
        }
        
        var result = Array<UInt32>(reserveCapacity: 16)
        for idx in stride(from: startIndex, to: endIndex, by: 4) {
            let val = UInt32(bytes: self, fromIndex: idx).bigEndian
            result.append(val)
        }
        
        return result
    }
    
    // Big endian order
    func toUInt64Array() -> Array<UInt64> {
        if isEmpty {
            return []
        }
        
        var result = Array<UInt64>(reserveCapacity: 32)
        for idx in stride(from: startIndex, to: endIndex, by: 8) {
            let val = UInt64(bytes: self, fromIndex: idx).bigEndian
            result.append(val)
        }
        
        return result
    }
}

extension Array where Element == UInt8 {
    init(hex: String) {
        self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
        var buffer: UInt8?
        var skip = hex.hasPrefix("0x") ? 2 : 0
        for char in hex.unicodeScalars.lazy {
            guard skip == 0 else {
                skip -= 1
                continue
            }
            guard char.value >= 48 && char.value <= 102 else {
                removeAll()
                return
            }
            let v: UInt8
            let c: UInt8 = UInt8(char.value)
            switch c {
            case let c where c <= 57:
                v = c - 48
            case let c where c >= 65 && c <= 70:
                v = c - 55
            case let c where c >= 97:
                v = c - 87
            default:
                removeAll()
                return
            }
            if let b = buffer {
                append(b << 4 | v)
                buffer = nil
            } else {
                buffer = v
            }
        }
        if let b = buffer {
            append(b)
        }
    }
    
    func toHexString() -> String {
        return `lazy`.reduce("") {
            var s = String($1, radix: 16)
            if s.count == 1 {
                s = "0" + s
            }
            return $0 + s
        }
    }
}
