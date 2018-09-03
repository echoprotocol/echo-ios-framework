//
//  BlockData.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 28.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    This class encapsulates all block-related information needed in order to build a valid transaction.
 */
struct BlockData: BytesEncodable {
    
    static let refBlockNumBytes = 2
    static let refBlockPrefixBytes = 4
    static let refBlockEcpirationBytes = 4
    static let refBlockPrefixRadix = 16
    static let refBlokPrefixEnd = 6
    static let refBlockNumBits = 0xFFF
    
    static let headHashBytes = 8
    static let headHashStep = 2
    static let headHashStart = 8
    static let headHashEnd = 16
    
    static let offset = 8
    
    let refBlockNum: Int
    let refBlockPrefix: Int
    var relativeExpiration: Int
    
    init(headBlockNumber: Int, headBlockId: String, relativeExpiration: Int) {
        
        self.relativeExpiration = relativeExpiration
        self.refBlockNum = BlockData.blockNumConvert(headBlockNumber)
        self.refBlockPrefix = BlockData.toRefBlockPrefix(headBlockId: headBlockId)
    }
    
    static func blockNumConvert(_ headBlockNumber: Int) -> Int {
        return Int(Int32(truncatingIfNeeded: headBlockNumber) & 0xFFFF)
    }
    
    static func toRefBlockPrefix(headBlockId: String) -> Int {
        
        let startIndex = String.Index(encodedOffset: headHashStart)
        let endIndex = String.Index(encodedOffset: headHashEnd)
        let hashData = String(headBlockId[startIndex..<endIndex])
        var prefixData = String()
        for index in stride(from: 0, to: headHashBytes, by: headHashStep) {
            let fromIndex = String.Index(encodedOffset: headHashBytes - headHashStep - index)
            let toIndex = String.Index(encodedOffset: headHashBytes - index)
            prefixData.append(String(hashData[fromIndex..<toIndex]))
        }
        return Int(prefixData, radix: refBlockPrefixRadix) ?? 0
    }
    
    func toData() -> Data? {
        
        var result = Data(count: BlockData.refBlockNumBytes + BlockData.refBlockPrefixBytes + BlockData.refBlockEcpirationBytes)
        
        let refBlockNum = Int32(truncatingIfNeeded: self.refBlockNum)
        let refBlockPrefix = Int64(truncatingIfNeeded: self.refBlockPrefix)
        let relativeExpiration = Int64(truncatingIfNeeded: self.relativeExpiration)
        
        for index in 0..<result.count {
            switch index {
            case 0..<BlockData.refBlockNumBytes:
                result[index] = UInt8(truncatingIfNeeded: refBlockNum >> Int32(BlockData.offset * index))
            case BlockData.refBlockNumBytes..<BlockData.refBlokPrefixEnd:
                result[index] = UInt8(truncatingIfNeeded: refBlockPrefix >> Int64(BlockData.offset * (index - BlockData.refBlockNumBytes)))
            default:
                result[index] = UInt8(truncatingIfNeeded: relativeExpiration >> Int64(BlockData.offset * (index - BlockData.refBlokPrefixEnd)))
            }
        }
        
        return result
    }
}
