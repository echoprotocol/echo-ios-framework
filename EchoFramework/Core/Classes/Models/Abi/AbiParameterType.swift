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
    case ethContractAddress
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
        case .array: fallthrough
        case .dynamicArrayOfUint: fallthrough
        case .fixedArrayOfInt: fallthrough
        case .dynamicArrayOfInt: fallthrough
        case .fixedArrayOfBool: fallthrough
        case .dynamicArrayOfBool: fallthrough
        case .fixedArrayOfBytes: fallthrough
        case .dynamicArrayOfBytes: fallthrough
        case .fixedArrayOfStrings: fallthrough
        case .dynamicArrayOfStrings: fallthrough
        case .fixedArrayOfFixedBytes: fallthrough
        case .dynamicArrayOfFixedBytes: fallthrough
        case .fixedArrayOfAddresses: fallthrough
        case .dynamicArrayOfAddresses: fallthrough
        case .fixedArrayOfUint:

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
        case .fixedArrayOfUint: fallthrough
        case .fixedArrayOfInt: fallthrough
        case .fixedArrayOfBool: fallthrough
        case .fixedArrayOfBytes: fallthrough
        case .fixedArrayOfFixedBytes: fallthrough
        case .fixedArrayOfAddresses:
            return true
        default:
            return false
        }
    }
}

extension AbiParameterType: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        
        switch self {
            
        case .string:
            hasher.combine("string")
            
        case .address, .contractAddress, .ethContractAddress:
            hasher.combine("address")
            
        case .bool:
            hasher.combine("bool")
            
        case .unknown:
            hasher.combine("unknown")
            
        case .uint(_):
            hasher.combine("uint")
            
        case .int(_):
            hasher.combine("int")
            
        case .bytes:
            hasher.combine("bytes")
            
        case .fixedBytes(_):
            hasher.combine("fixedBytes")
            
        case .array(_):
            hasher.combine("array")
            
        case .fixedArrayOfUint(_):
            hasher.combine("fixedArrayOfUint")
            
        case .dynamicArrayOfUint:
            hasher.combine("dynamicArrayOfUint")
            
        case .fixedArrayOfInt(_):
            hasher.combine("fixedArrayOfInt")
            
        case .dynamicArrayOfInt:
            hasher.combine("dynamicArrayOfInt")
            
        case .fixedArrayOfBool(_):
            hasher.combine("fixedArrayOfBool")
            
        case .dynamicArrayOfBool:
            hasher.combine("dynamicArrayOfBool")
            
        case .fixedArrayOfBytes(_):
            hasher.combine("fixedArrayOfBytes")
            
        case .dynamicArrayOfBytes:
            hasher.combine("dynamicArrayOfBytes")
            
        case .fixedArrayOfStrings(_):
            hasher.combine("fixedArrayOfStrings")
            
        case .dynamicArrayOfStrings:
            hasher.combine("dynamicArrayOfStrings")
            
        case .fixedArrayOfFixedBytes:
            hasher.combine("fixedArrayOfFixedBytes")
            
        case .dynamicArrayOfFixedBytes:
            hasher.combine("dynamicArrayOfFixedBytes")
            
        case .fixedArrayOfAddresses(_):
            hasher.combine("fixedArrayOfAddresses")
            
        case .dynamicArrayOfAddresses:
            hasher.combine("dynamicArrayOfAddresses")
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
            
        case (.ethContractAddress, ethContractAddress):
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
            
        case let (.fixedArrayOfFixedBytes(leftBytesSize, leftArraySize), .fixedArrayOfFixedBytes(rightBytesSize, rightArraySize)):
            return leftBytesSize == rightBytesSize && leftArraySize == rightArraySize
            
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
            
        case .address, .contractAddress, .ethContractAddress:
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
