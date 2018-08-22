//
//  DataEncodingTests.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 22.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class DataEncodingTests: XCTestCase {
    
    func testBoolEncode() {
        
        //arrange
        let value = true
        //act
        let encoded = Data.fromBool(value)
        //assert
        XCTAssertEqual(encoded.hex, "01")
    }
    
    func testInt8Encode() {
        
        //arrange
        let value = 1
        //act
        let encoded = Data.fromInt8(value)
        //assert
        XCTAssertEqual(encoded.hex, "01")
    }
    
    func testInt16Encode() {
        
        //arrange
        let value = 1
        //act
        let encoded = Data.fromInt16(value)
        //assert
        XCTAssertEqual(encoded.hex, "0001")
    }
    
    func testInt32Encode() {
        
        //arrange
        let value = 1
        //act
        let encoded = Data.fromInt32(value)
        //assert
        XCTAssertEqual(encoded.hex, "00000001")
    }
    
    func testInt64Encode() {
        
        //arrange
        let value = 1
        //act
        let encoded = Data.fromInt64(value)
        //assert
        XCTAssertEqual(encoded.hex, "0000000000000001")
    }
    
    func testUnt64Encode() {
        
        //arrange
        let value: UInt = 1
        //act
        let encoded = Data.fromUint64(value)
        //assert
        XCTAssertEqual(encoded.hex, "0000000000000001")
    }
    
    func testUntEncodeBytes() {
        
        //arrange
        let value: UInt = 10000
        //act
        let encoded = Data.fromUIntLikeUnsignedByteArray(value)
        //assert
        XCTAssertEqual(encoded.hex, "2710")
    }
    
    func testHexEncode() {
        
        //arrange
        let value = "000102030405060708090a0b0c0d0e0f"
        //act
        let data = Data(hex: value)
        //assert
        XCTAssertNotNil(data)
        XCTAssertEqual(data!.hex, "000102030405060708090a0b0c0d0e0f")
    }
    
    func testAppendData() {
        
        //arrange
        let value = true
        let value2 = true
        
        //act
        var data = Data.fromBool(value)
        let data2 = Data.fromBool(value2)
        data.append(optional: data2)
        
        //assert
        XCTAssertEqual(data.hex, "0101")
    }
    
    func testDataGeneric() {
        
        //arrange
        let value = true
        
        //act
        let data = Data(from: value)
        
        //assert
        XCTAssertEqual(data.hex, "01")
    }
}
