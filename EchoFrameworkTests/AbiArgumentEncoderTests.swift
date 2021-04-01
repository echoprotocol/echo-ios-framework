//
//  AbiArgumentEncoderTests.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 13.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import XCTest
@testable import EchoFramework

class AbiArgumentEncoderTests: XCTestCase {
    
    var interpretator: AbiArgumentCoder = AbiArgumentCoderImp()
    
    func testEncodeUint256AndString() {
        
        //arrange
        let decodedParams = "000000000000000000000000000000000000000000000000000000000000007b0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20576f726c642100000000000000000000000000000000000000"
        let typeValue = [AbiTypeValueInputModel(type: .uint(size: 256), value: "123"),
                         AbiTypeValueInputModel(type: .string, value: "Hello, World!")]
        
        //act
        let data = try? interpretator.getArguments(valueTypes: typeValue)
        
        //assert
        XCTAssertNotNil(data?.hex)
        XCTAssertEqual(data?.hex, decodedParams)
    }
    
    func testEncodeUint256AndUint256AndString() {
        
        //arrange
        let decodedParams = "000000000000000000000000000000000000000000000000000000000000007b00000000000000000000000000000000000000000000000000000000000001c800000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000023746865717569636b62726f776e666f786a756d70736f7665727468656c617a79646f670000000000000000000000000000000000000000000000000000000000"
        let typeValue = [AbiTypeValueInputModel(type: .uint(size: 256), value: "123"),
                         AbiTypeValueInputModel(type: .uint(size: 256), value: "456"),
                         AbiTypeValueInputModel(type: .string, value: "thequickbrownfoxjumpsoverthelazydog")]
        
        //act
        let data = try? interpretator.getArguments(valueTypes: typeValue)
        
        //assert
        XCTAssertNotNil(data?.hex)
        XCTAssertEqual(data?.hex, decodedParams)
    }
    
    func testEncodeUint256AndUint256AndStringAndString() {
        
        //arrange
        let decodedParams = "000000000000000000000000000000000000000000000000000000000000007b00000000000000000000000000000000000000000000000000000000000001c8000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000023746865717569636b62726f776e666f786a756d70736f7665727468656c617a79646f670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e73686573656c6c737365617368656c6c736f6e74686573656173686f72650000"
        let typeValue = [AbiTypeValueInputModel(type: .uint(size: 256), value: "123"),
                         AbiTypeValueInputModel(type: .uint(size: 256), value: "456"),
                         AbiTypeValueInputModel(type: .string, value: "thequickbrownfoxjumpsoverthelazydog"),
                         AbiTypeValueInputModel(type: .string, value: "shesellsseashellsontheseashore")]
        
        //act
        let data = try? interpretator.getArguments(valueTypes: typeValue)
        
        //assert
        XCTAssertNotNil(data?.hex)
        XCTAssertEqual(data?.hex, decodedParams)
    }
    
    func testEncodeAddress() {
        
        //arrange
        let decodedParams = "0000000000000000000000000000000000000000000000000000000000000012"
        let typeValue = [AbiTypeValueInputModel(type: .address, value: "18")]

        //act
        let data = try? interpretator.getArguments(valueTypes: typeValue)
        
        //assert
        XCTAssertNotNil(data?.hex)
        XCTAssertEqual(data?.hex, decodedParams)
    }
    
    func testEncodeContractAddress() {
        
        //arrange
        let decodedParams = "00000000000000000000000001000000000000000000000000000000000041a3"
        let typeValue = [AbiTypeValueInputModel(type: .contractAddress, value: "16803")]
        
        //act
        let data = try? interpretator.getArguments(valueTypes: typeValue)
        
        //assert
        XCTAssertNotNil(data?.hex)
        XCTAssertEqual(data?.hex, decodedParams)
    }
    
    func testEncodeETHContractAddress() {
        
        //arrange
        let decodedParams = "000000000000000000000000ca35b7d915458ef540ade6068dfe2f44e8fa733c"
        let typeValue = [AbiTypeValueInputModel(type: .ethContractAddress, value: "0xca35b7d915458ef540ade6068dfe2f44e8fa733c")]
        
        //act
        let data = try? interpretator.getArguments(valueTypes: typeValue)
        
        //assert
        XCTAssertNotNil(data?.hex)
        XCTAssertEqual(data?.hex, decodedParams)
    }
    
    func testEncodeETHContractAddressWithout0x() {
        
        //arrange
        let decodedParams = "000000000000000000000000ca35b7d915458ef540ade6068dfe2f44e8fa733c"
        let typeValue = [AbiTypeValueInputModel(type: .ethContractAddress, value: "ca35b7d915458ef540ade6068dfe2f44e8fa733c")]
        
        //act
        let data = try? interpretator.getArguments(valueTypes: typeValue)
        
        //assert
        XCTAssertNotNil(data?.hex)
        XCTAssertEqual(data?.hex, decodedParams)
    }
    
    func testEncodeAddressAndUint256AndUint256AndStringAndString() {
        
        //arrange
        let decodedParams = "0000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000007b00000000000000000000000000000000000000000000000000000000000001c800000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000023746865717569636b62726f776e666f786a756d70736f7665727468656c617a79646f670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e73686573656c6c737365617368656c6c736f6e74686573656173686f72650000"
        let typeValue = [AbiTypeValueInputModel(type: .address, value: "18"),
                         AbiTypeValueInputModel(type: .uint(size: 256), value: "123"),
                         AbiTypeValueInputModel(type: .uint(size: 256), value: "456"),
                         AbiTypeValueInputModel(type: .string, value: "thequickbrownfoxjumpsoverthelazydog"),
                         AbiTypeValueInputModel(type: .string, value: "shesellsseashellsontheseashore")]
        
        //act
        let data = try? interpretator.getArguments(valueTypes: typeValue)
        
        //assert
        XCTAssertNotNil(data?.hex)
        XCTAssertEqual(data?.hex, decodedParams)
    }
    
    func testEncodeBoolAndStringAndStringAndUint8AndBool() {
        
        //arrange
        let decodedParams = "000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002736400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036173640000000000000000000000000000000000000000000000000000000000"
        let typeValue = [AbiTypeValueInputModel(type: .bool, value: "1"),
                         AbiTypeValueInputModel(type: .string, value: "sd"),
                         AbiTypeValueInputModel(type: .string, value: "asd"),
                         AbiTypeValueInputModel(type: .uint(size: 8), value: "255"),
                         AbiTypeValueInputModel(type: .bool, value: "false")]
        
        //act
        let data = try? interpretator.getArguments(valueTypes: typeValue)
        
        //assert
        XCTAssertNotNil(data?.hex)
        XCTAssertEqual(data?.hex, decodedParams)
    }
    
    func testEncodeEtherExampleBytesAndBoolAndDynamicArrayOfUints() {
        
        //arrange
        let decodedParams = "0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000464617665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003"
        let typeValue = [
            AbiTypeValueInputModel(type: .bytes, value: "dave"),
            AbiTypeValueInputModel(type: .bool, value: "1"),
            AbiTypeValueInputModel(type: .dynamicArrayOfUint, value: "[1,2,3]")
        ]
        
        //act
        let data = try? interpretator.getArguments(valueTypes: typeValue)
        
        //assert
        XCTAssertNotNil(data?.hex)
        XCTAssertEqual(data?.hex, decodedParams)
    }
    
    func testFromExamples() {
        
        //arrange
        let decodedParams = "00000000000000000000000000000000000000000000000000000000000001230000000000000000000000000000000000000000000000000000000000000080313233343536373839300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000004560000000000000000000000000000000000000000000000000000000000000789000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000"
        let typeValue = [
            AbiTypeValueInputModel(type: .uint(size: 256), value: "291"),
            AbiTypeValueInputModel(type: .dynamicArrayOfUint, value: "[1110,1929]"),
            AbiTypeValueInputModel(type: .fixedBytes(size: 10), value: "1234567890"),
            AbiTypeValueInputModel(type: .bytes, value: "Hello, world!")
        ]
        
        //act
        let data = try? interpretator.getArguments(valueTypes: typeValue)
        
        //assert
        XCTAssertNotNil(data?.hex)
        XCTAssertEqual(data?.hex, decodedParams)
    }
    
    func testEncodeEtherExampleUintAndDynamicArrayOfUintsAndBytes10AndBytes() {
        
        //arrange
        let decodedParams = "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000080313233343536373839300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000"
        let typeValue = [
            AbiTypeValueInputModel(type: .uint(size: 256), value: "1"),
            AbiTypeValueInputModel(type: .dynamicArrayOfUint, value: "[2,3]"),
            AbiTypeValueInputModel(type: .fixedBytes(size: 10), value: "1234567890"),
            AbiTypeValueInputModel(type: .bytes, value: "Hello, world!")
        ]
        
        //act
        let data = try? interpretator.getArguments(valueTypes: typeValue)
        
        //assert
        XCTAssertNotNil(data?.hex)
        XCTAssertEqual(data?.hex, decodedParams)
    }
    
    func testEncodeUintAndDynamicArrayOfAddressesAndBytes10AndBytes() {
        
        //arrange
        let decodedParams = "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000080313233343536373839300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000"
        let typeValue = [
            AbiTypeValueInputModel(type: .uint(size: 256), value: "1"),
            AbiTypeValueInputModel(type: .dynamicArrayOfUint, value: "[18,18]"),
            AbiTypeValueInputModel(type: .fixedBytes(size: 10), value: "1234567890"),
            AbiTypeValueInputModel(type: .bytes, value: "Hello, world!")
        ]
        
        //act
        let data = try? interpretator.getArguments(valueTypes: typeValue)
        
        //assert
        XCTAssertNotNil(data?.hex)
        XCTAssertEqual(data?.hex, decodedParams)
    }
    
    func testEncodeUintAndDynamicArrayOfBytes32AndBytes10AndBytes() {
        
        //arrange
        let decodedParams = "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000080313233343536373839300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000231323334353637383930000000000000000000000000000000000000000000003132333435363738393000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000"
        let typeValue = [
            AbiTypeValueInputModel(type: .uint(size: 256), value: "1"),
            AbiTypeValueInputModel(type: .dynamicArrayOfFixedBytes(size: 32), value: "[1234567890,1234567890]"),
            AbiTypeValueInputModel(type: .fixedBytes(size: 10), value: "1234567890"),
            AbiTypeValueInputModel(type: .bytes, value: "Hello, world!")
        ]
        
        //act
        let data = try? interpretator.getArguments(valueTypes: typeValue)
        
        //assert
        XCTAssertNotNil(data?.hex)
        XCTAssertEqual(data?.hex, decodedParams)
    }
    
    func testEncodeUintAndFixedArrayOfBytes32AndBytes10AndBytes() {
        
        //arrange
        let decodedParams = "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000080313233343536373839300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000231323334353637383930000000000000000000000000000000000000000000003132333435363738393000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000"
        let typeValue = [
            AbiTypeValueInputModel(type: .uint(size: 256), value: "1"),
            AbiTypeValueInputModel(type: .fixedArrayOfFixedBytes(bytesSize: 32, arraySize: 2), value: "[1234567890,1234567890]"),
            AbiTypeValueInputModel(type: .fixedBytes(size: 10), value: "1234567890"),
            AbiTypeValueInputModel(type: .bytes, value: "Hello, world!")
        ]
        
        //act
        let data = try? interpretator.getArguments(valueTypes: typeValue)
        
        //assert
        XCTAssertNotNil(data?.hex)
        XCTAssertEqual(data?.hex, decodedParams)
    }
    
    func testEncodeTransferParamEncodeAddressAndUint256() {
        
        //arrange
        let decodedParams = "00000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000064"
        let typeValue = [
            AbiTypeValueInputModel(type: .address, value: "18"),
            AbiTypeValueInputModel(type: .uint(size: 256), value: "100")
        ]
        
        //act
        let data = try? interpretator.getArguments(valueTypes: typeValue)
        
        //assert
        XCTAssertNotNil(data?.hex)
        XCTAssertEqual(data?.hex, decodedParams)
    }
    
    func testEncodeDynamicArrayOfStrings() {
        
        //arrange
        let decodedParams = "00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000"
        let typeValue = [
            AbiTypeValueInputModel(type: .dynamicArrayOfStrings, value: "[\"Hello, world!\",\"Hello, world!\",\"Hello, world!\"]")
        ]
        
        //act
        let data = try? interpretator.getArguments(valueTypes: typeValue)
        
        //assert
        XCTAssertNotNil(data?.hex)
        XCTAssertEqual(data?.hex, decodedParams)
    }
}
