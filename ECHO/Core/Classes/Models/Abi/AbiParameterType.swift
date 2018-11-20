//
//  AbiParameterType.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 01.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

// swiftlint:disable no_fallthrough_only
public enum AbiParameterType {
    
    case string
    case uint(size: Int)
    case int(size: Int)
    case bool
    case bytes
    case address
    case contractAddress
    case fixedBytes(size: Int)
    case array(size: Int)
    case fixedArrayOfUint(size: Int)
    case dynamicArrayOfUint
    case fixedArrayOfInt(size: Int)
    case dynamicArrayOfInt
    case fixedArrayOfBool(size: Int)
    case dynamicArrayOfBool
    case fixedArrayOfBytes(size: Int)
    case dynamicArrayOfBytes
    case fixedArrayOfStrings(size: Int)
    case dynamicArrayOfStrings
    case fixedArrayOfFixedBytes(bytesSize: Int, arraySize: Int)
    case dynamicArrayOfFixedBytes(size: Int)
    case fixedArrayOfAddresses(size: Int)
    case dynamicArrayOfAddresses
    case unknown
    
    func isArray() -> Bool {
        
        switch self {
        case .array(_): fallthrough
        case .dynamicArrayOfUint: fallthrough
        case .fixedArrayOfInt(_): fallthrough
        case .dynamicArrayOfInt: fallthrough
        case .fixedArrayOfBool(_): fallthrough
        case .dynamicArrayOfBool: fallthrough
        case .fixedArrayOfBytes(_): fallthrough
        case .dynamicArrayOfBytes: fallthrough
        case .fixedArrayOfStrings(_): fallthrough
        case .dynamicArrayOfStrings: fallthrough
        case .fixedArrayOfFixedBytes(_): fallthrough
        case .dynamicArrayOfFixedBytes: fallthrough
        case .fixedArrayOfAddresses(_): fallthrough
        case .dynamicArrayOfAddresses: fallthrough
        case .fixedArrayOfUint(_):

            return true
        default:
            return false
        }
    }
    
    func isPrimitive() -> Bool {
        
        switch self {
        case .bool: fallthrough
        case .fixedBytes(_): fallthrough
        case .int(_): fallthrough
        case .uint(_):
            
            return true
        default:
            return false
        }
    }
    
    func isDynamicElementaryArray() -> Bool {
        
        switch self {
        case .dynamicArrayOfUint: fallthrough
        case .dynamicArrayOfInt: fallthrough
        case .dynamicArrayOfBool: fallthrough
        case .dynamicArrayOfBytes: fallthrough
        case .dynamicArrayOfFixedBytes: fallthrough
        case .dynamicArrayOfAddresses:
            return true
        default:
            return false
        }
    }
    
    func isFixedElementaryArray() -> Bool {
        
        switch self {
        case .fixedArrayOfUint(_): fallthrough
        case .fixedArrayOfInt(_): fallthrough
        case .fixedArrayOfBool(_): fallthrough
        case .fixedArrayOfBytes(_): fallthrough
        case .fixedArrayOfFixedBytes(_): fallthrough
        case .fixedArrayOfAddresses(_):
            return true
        default:
            return false
        }
    }
}

extension AbiParameterType: Hashable {
    
    public var hashValue: Int {
        
        switch self {
            
        case .string:
            return "string".hashValue
            
        case .address, .contractAddress:
            return "address".hashValue
            
        case .bool:
            return "bool".hashValue
            
        case .unknown:
            return "unknown".hashValue
            
        case .uint(_):
            
            return "uint".hashValue
            
        case .int(_):
            
            return "int".hashValue
            
        case .bytes:
            
            return "bytes".hashValue
            
        case .fixedBytes(_):
            
            return "fixedBytes".hashValue
            
        case .array(_):
            
            return "array".hashValue
            
        case .fixedArrayOfUint(_):
            
            return "fixedArrayOfUint".hashValue
            
        case .dynamicArrayOfUint:
            
            return "dynamicArrayOfUint".hashValue
            
        case .fixedArrayOfInt(_):
            
            return "fixedArrayOfInt".hashValue
            
        case .dynamicArrayOfInt:
            
            return "dynamicArrayOfInt".hashValue
            
        case .fixedArrayOfBool(_):
            
            return "fixedArrayOfBool".hashValue
            
        case .dynamicArrayOfBool:
            
            return "dynamicArrayOfBool".hashValue
            
        case .fixedArrayOfBytes(_):
            
            return "fixedArrayOfBytes".hashValue
            
        case .dynamicArrayOfBytes:
            
            return "dynamicArrayOfBytes".hashValue
            
        case .fixedArrayOfStrings(_):
            
            return "fixedArrayOfStrings".hashValue
            
        case .dynamicArrayOfStrings:
            
            return "dynamicArrayOfStrings".hashValue
            
        case .fixedArrayOfFixedBytes(_):
            
            return "fixedArrayOfFixedBytes".hashValue
            
        case .dynamicArrayOfFixedBytes:
            
            return "dynamicArrayOfFixedBytes".hashValue
            
        case .fixedArrayOfAddresses(_):
            
            return "fixedArrayOfAddresses".hashValue
            
        case .dynamicArrayOfAddresses:
            
            return "dynamicArrayOfAddresses".hashValue
        }
    }
}

extension AbiParameterType: Equatable {
    
    public static func == (lhs: AbiParameterType, rhs: AbiParameterType) -> Bool {
        
        switch (lhs, rhs) {
            
        case (.string, .string):
            return true
            
        case (.address, .address):
            return true
            
        case (.contractAddress, .contractAddress):
            return true
            
        case (.bool, .bool):
            return true
            
        case (.unknown, .unknown):
            return true
            
        case (.uint(_), .uint(_)):
            
            return true
            
        case (.int(_), .int(_)):
            
            return true
            
        case (.bytes, .bytes):
            
            return true
            
        case let (.fixedBytes(left), .fixedBytes(right)):
            
            return left == right
            
        case let (.array(left), .array(right)):
            
            return left == right
            
        case let (.fixedArrayOfUint(left), .fixedArrayOfUint(right)):
            
            return left == right
            
        case (.dynamicArrayOfUint, .dynamicArrayOfUint):
            
            return true
            
        case let (.fixedArrayOfInt(left), .fixedArrayOfInt(right)):
            
            return left == right
            
        case  (.dynamicArrayOfInt, .dynamicArrayOfInt):
            
            return true
            
        case let (.fixedArrayOfBool(left), .fixedArrayOfBool(right)):
            
            return left == right
            
        case (.dynamicArrayOfBool, .dynamicArrayOfBool):
            
            return true
            
        case let (.fixedArrayOfBytes(left), .fixedArrayOfBytes(right)):
            
            return left == right
            
        case (.dynamicArrayOfBytes, .dynamicArrayOfBytes):
            
            return true
            
        case let (.fixedArrayOfStrings(left), .fixedArrayOfStrings(right)):
            
            return left == right
            
        case (.dynamicArrayOfStrings, .dynamicArrayOfStrings):
            
            return true
            
        case let (.fixedArrayOfFixedBytes(left), .fixedArrayOfFixedBytes(right)):
            
            return left == right
            
        case (.dynamicArrayOfFixedBytes, .dynamicArrayOfFixedBytes):
            
            return true
            
        case let (.fixedArrayOfAddresses(left), .fixedArrayOfAddresses(right)):
            
            return left == right
            
        case (.dynamicArrayOfAddresses, .dynamicArrayOfAddresses):
            
            return true
            
        default:
            return false
        }
    }
}

extension AbiParameterType: CustomStringConvertible {
    
    public var description: String {
        
        switch self {
            
        case .string:
            return "string"
            
        case .address, .contractAddress:
            return "address"
            
        case .bool:
            return "bool"
            
        case .unknown:
            return "unknown"
            
        case .uint(let size):
            
            return "uint" + "\(size)"
            
        case .int(let size):
            
            return "int" + "\(size)"
            
        case .bytes:
            
            return "bytes"
            
        case .fixedBytes(let size):
            
            return "bytes" + "\(size)"
            
        case .array(_):
            
            return "array"
            
        case .fixedArrayOfUint(let size):
            
            return "uint" + "[\(size)]"

        case .dynamicArrayOfUint:
            
            return "uint" + "[]"

        case .fixedArrayOfInt(let size):
            
            return "int" + "[\(size)]"

        case .dynamicArrayOfInt:
            
            return "int" + "[]"

        case .fixedArrayOfBool(let size):
            
            return "bool" + "[\(size)]"

        case .dynamicArrayOfBool:
            
            return "bool" + "[]"

        case .fixedArrayOfBytes(let size):
            
            return "bytes" + "[\(size)]"

        case .dynamicArrayOfBytes:
            
            return "bytes" + "[]"

        case .fixedArrayOfStrings(let size):
            
            return "string" + "[\(size)]"

        case .dynamicArrayOfStrings:
            
            return "string" + "[]"

        case .fixedArrayOfFixedBytes(let bytesSize, let arraySize):
            
            return "bytes" + "\(bytesSize)" + "[\(arraySize)]"

        case .dynamicArrayOfFixedBytes(let bytesSize):
            
            return "bytes" + "\(bytesSize)" + "[]"

        case .fixedArrayOfAddresses(let size):
            
            return "address" + "[\(size)]"

        case .dynamicArrayOfAddresses:
            
            return "address" + "[]"
        }
    }
}
// swiftlint:enable no_fallthrough_only
