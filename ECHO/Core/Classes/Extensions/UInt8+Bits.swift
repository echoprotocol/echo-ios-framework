//
//  UInt8+Bits.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 16.10.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

extension UInt8 {
    
    func bits() -> [Bit] {
        let bitsOfAbyte = 8
        var bits = [Bit](repeating: .zero, count: 8)
        for index in 0..<8 {
            let bitVal: UInt8 = 1 << UInt8(bitsOfAbyte - 1 - index)
            let check = self & bitVal
            
            if check != 0 {
                bits[index] = Bit.one
            }
        }

        return bits
    }
}

enum Bit: UInt8, CustomStringConvertible {
    case zero, one

    var description: String {
        switch self {
        case .one:
            return "1"
        case .zero:
            return "0"
        }
    }
}
