//
//  String+Extension.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 13.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

extension String {
    
    public var bytes: Array<UInt8> {
        return data(using: String.Encoding.utf8, allowLossyConversion: true)?.bytes ?? Array(utf8)
    }

    public func sha3(_ variant: SHA3.Variant) -> String {
        return SHA3(variant: variant).calculate(for: bytes).toHexString()
    }
    
    subscript(_ range: CountableRange<Int>) -> String {
        
        let idx1 = index(startIndex, offsetBy: range.lowerBound)
        let idx2 = index(startIndex, offsetBy: range.upperBound)
        return String(self[idx1..<idx2])
    }
}
