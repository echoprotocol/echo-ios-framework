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
        XCTAssertEqual(encoded.hex, "0100")
    }
    
    func testInt32Encode() {
        
        //arrange
        let value = 1
        //act
        let encoded = Data.fromInt32(value)
        //assert
        XCTAssertEqual(encoded.hex, "01000000")
    }
    
    func testInt64Encode() {
        
        //arrange
        let value = 1
        //act
        let encoded = Data.fromInt64(value)
        //assert
        XCTAssertEqual(encoded.hex, "0100000000000000")
    }
    
    func testUnt64Encode() {
        
        //arrange
        let value: UInt = 1
        //act
        let encoded = Data.fromUint64(value)
        //assert
        XCTAssertEqual(encoded.hex, "0100000000000000")
    }
    
    func testUntEncodeBytes() {
        
        //arrange
        let value: UInt = 10000
        //act
        let encoded = Data.fromUIntLikeUnsignedByteArray(value)
        //assert
        XCTAssertEqual(encoded.hex, "904e")
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
    
    func testBase58_1() {
    
        //assert
        XCTAssertEqual(Base58.decode("1EVEDmVcV7iPvTkaw2gk89yVcCzPzaS6B7").hex, "0093f051563b089897cb430602a7c35cd93b3cc8e9dfac9a96")
        XCTAssertEqual(Base58.decode("11ujQcjgoMNmbmcBkk8CXLWQy8ZerMtuN").hex, "00002c048b88f56727538eadb2a81cfc350355ee4c466740d9")
        XCTAssertEqual(Base58.decode("111oeV7wjVNCQttqY63jLFsg817aMEmTw").hex, "000000abdda9e604c965f5a2fe8c082b14fafecdc39102f5b2")
    }
    
    func testBase58_2() {
        
        //arrange
        let original = Data(hex: "00010966776006953D5567439E5E39F86A0D273BEED61967F6")!
        
        //act
        let encoded = Base58.encode(original)
        let decoded = Base58.decode(encoded)

        //assert
        XCTAssertEqual(encoded, "16UwLL9Risc3QfPqBUvKofHmBQ7wMtjvM")
        XCTAssertEqual(decoded.hex, original.hex)
    }
}
