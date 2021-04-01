//
//  AbiParameterValidation.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 01.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class AbiParameterValidationTests: XCTestCase {
    
    func testValidationUInt() {
        
        //arrange
        var value = "uint32"
        //assert
        XCTAssertTrue(value.isUint())
        //arrange
        value = "uint"
        //assert
        XCTAssertTrue(value.isUint())
        //arrange
        value = "uint32sd"
        //assert
        XCTAssertFalse(value.isUint())
        //arrange
        value = "uin32"
        //assert
        XCTAssertFalse(value.isUint())
        //arrange
        value = "int32"
        //assert
        XCTAssertFalse(value.isUint())
        //arrange
        value = "uint[]"
        //assert
        XCTAssertFalse(value.isUint())
    }
    
    func testValidationInt() {
        
        //arrange
        var value = "int32"
        //assert
        XCTAssertTrue(value.isInt())
        //arrange
        value = "int256"
        //assert
        XCTAssertTrue(value.isInt())
        //arrange
        value = "int32sd"
        //assert
        XCTAssertFalse(value.isInt())
        //arrange
        value = "int"
        //assert
        XCTAssertTrue(value.isInt())
        //arrange
        value = "uin32"
        //assert
        XCTAssertFalse(value.isInt())
        //arrange
        value = "int3s2"
        //assert
        XCTAssertFalse(value.isInt())
        //arrange
        value = "uint[]"
        //assert
        XCTAssertFalse(value.isInt())
    }
    
    func testValidationFixedBytes() {
        
        //arrange
        var value = "bytes9"
        //assert
        XCTAssertTrue(value.isFixedBytes())
        //arrange
        value = "bytes32"
        //assert
        XCTAssertTrue(value.isFixedBytes())
        //arrange
        value = "bytes"
        //assert
        XCTAssertFalse(value.isFixedBytes())
        //arrange
        value = "bytes[9]"
        //assert
        XCTAssertFalse(value.isFixedBytes())
        //arrange
        value = "bytes[0s]"
        //assert
        XCTAssertFalse(value.isFixedBytes())
        //arrange
        value = "int[]"
        //assert
        XCTAssertFalse(value.isFixedBytes())
        //arrange
        value = "bytes[a]"
        //assert
        XCTAssertFalse(value.isFixedBytes())
    }
    
    func testValidationBytes() {
        
        //arrange
        var value = "bytes"
        //assert
        XCTAssertTrue(value.isBytes())
        //arrange
        value = "bytes32"
        //assert
        XCTAssertFalse(value.isBytes())
        //arrange
        value = "bytes[9]"
        //assert
        XCTAssertFalse(value.isBytes())
        //arrange
        value = "bytes[0s]"
        //assert
        XCTAssertFalse(value.isBytes())
        //arrange
        value = "int[]"
        //assert
        XCTAssertFalse(value.isBytes())
        //arrange
        value = "bytes[a]"
        //assert
        XCTAssertFalse(value.isBytes())
    }
    
    func testValidationArray() {
        
        //arrange
        var value = "bytes[]"
        //assert
        XCTAssertTrue(value.isArray())
        //arrange
        value = "bytes[a]"
        //assert
        XCTAssertFalse(value.isArray())
        //arrange
        value = "bytes[10]"
        //assert
        XCTAssertTrue(value.isArray())
    }
    
    func testAbiParameterValidation() {
        
        //arrange
        var value = "uint[]"
        //assert
        XCTAssertTrue(value.isDynamicArrayOfUint())
        XCTAssertFalse(value.isFixedArrayOfUint())
        //arrange
        value = "uinta[]"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfUint())
        XCTAssertFalse(value.isFixedArrayOfUint())
        //arrange
        value = "uint256[]"
        //assert
        XCTAssertTrue(value.isDynamicArrayOfUint())
        XCTAssertFalse(value.isFixedArrayOfUint())
        //arrange
        value = "uint256[]sd"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfUint())
        XCTAssertFalse(value.isFixedArrayOfUint())
        //arrange
        value = "uint[5]"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfUint())
        XCTAssertTrue(value.isFixedArrayOfUint())
        //arrange
        value = "uinta[]"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfUint())
        XCTAssertFalse(value.isFixedArrayOfUint())
        //arrange
        value = "uint256[5]"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfUint())
        XCTAssertTrue(value.isFixedArrayOfUint())
        //arrange
        value = "uint256[5]sd"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfUint())
        XCTAssertFalse(value.isFixedArrayOfUint())
    }
    
    func testValidationArrayOfInt() {
        
        //arrange
        var value = "int[]"
        //assert
        XCTAssertTrue(value.isDynamicArrayOfInt())
        XCTAssertFalse(value.isFixedArrayOfInt())
        //arrange
        value = "inta[]"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfInt())
        XCTAssertFalse(value.isFixedArrayOfInt())
        //arrange
        value = "int256[]"
        //assert
        XCTAssertTrue(value.isDynamicArrayOfInt())
        XCTAssertFalse(value.isFixedArrayOfInt())
        //arrange
        value = "int256[]sd"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfInt())
        XCTAssertFalse(value.isFixedArrayOfInt())
        //arrange
        value = "int[5]"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfInt())
        XCTAssertTrue(value.isFixedArrayOfInt())
        //arrange
        value = "inta[]"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfInt())
        XCTAssertFalse(value.isFixedArrayOfInt())
        //arrange
        value = "int256[5]"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfInt())
        XCTAssertTrue(value.isFixedArrayOfInt())
        //arrange
        value = "int256[5]sd"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfInt())
        XCTAssertFalse(value.isFixedArrayOfInt())
    }
    
    func testValidationArrayOfBool() {
        
        //arrange
        var value = "bool[]"
        //assert
        XCTAssertTrue(value.isDynamicArrayOfBool())
        XCTAssertFalse(value.isFixedArrayOfBool())
        //arrange
        value = "boola[]"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfBool())
        XCTAssertFalse(value.isFixedArrayOfBool())
        //arrange
        value = "bool256[]"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfBool())
        XCTAssertFalse(value.isFixedArrayOfBool())
        //arrange
        value = "bool256[]sd"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfBool())
        XCTAssertFalse(value.isFixedArrayOfBool())
        //arrange
        value = "bool[5]"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfBool())
        XCTAssertTrue(value.isFixedArrayOfBool())
        //arrange
        value = "boola[]"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfBool())
        XCTAssertFalse(value.isFixedArrayOfBool())
        //arrange
        value = "bool256[5]"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfBool())
        XCTAssertFalse(value.isFixedArrayOfBool())
        //arrange
        value = "bool256[5]sd"
        //assert
        XCTAssertFalse(value.isDynamicArrayOfBool())
        XCTAssertFalse(value.isFixedArrayOfBool())
    }
    
    func testValidationFixedBytesSize() {
        
        //arrange
        let value = "bytes9"
        //assert
        XCTAssertEqual(value.fixedBytesSize(), 9)
    }
    
    func testValidationUIntSize() {
        
        //arrange
        var value = "uint256"
        //assert
        XCTAssertEqual(value.uintSize(), 256)
        //arrange
        value = "uint33"
        //assert
        XCTAssertEqual(value.uintSize(), 33)
        //arrange
        value = "uint128"
        //assert
        XCTAssertEqual(value.uintSize(), 128)
        //arrange
        value = "uint8"
        //assert
        XCTAssertEqual(value.uintSize(), 8)
    }
    
    func testValidationIntSize() {
        
        //arrange
        var value = "int256"
        //assert
        XCTAssertEqual(value.intSize(), 256)
        //arrange
        value = "int33"
        //assert
        XCTAssertEqual(value.intSize(), 33)
        //arrange
        value = "int128"
        //assert
        XCTAssertEqual(value.intSize(), 128)
        //arrange
        value = "int8"
        //assert
        XCTAssertEqual(value.intSize(), 8)
    }
}
