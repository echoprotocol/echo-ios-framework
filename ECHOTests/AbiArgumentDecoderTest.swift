//
//  AbiArgumentDecoderTest.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 11/5/18.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class AbiArgumentDecoderTest: XCTestCase {
    
    var interpretator: AbiArgumentCoder = AbiArgumentCoderImp()
    
    func testDecodedTotalSupplyProperty() {
        
        //arrange
        let encodedString = "0000000000000000000000000000000000000000000000000000000000000298"
        let decodedString = "664"
        let type = AbiParameterType.uint(size: 256)
        let outputs = [AbiFunctionEntries(name: "", typeString: type.description, type: type)]
        var result: String?

        //act
        let values = try? interpretator.getValueTypes(string: encodedString, outputs: outputs)
        result = values?[safe: 0]?.value as? String
        
        //assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result, decodedString)
    }
    
    func testDecodedContractAddress() {
        
        //arrange
        let encodedString = "01000000000000000000000000000000000041a3"
        let decodedString = "16803"
        let type = AbiParameterType.contractAddress
        let outputs = [AbiFunctionEntries(name: "", typeString: type.description, type: type)]
        var result: String?
        
        //act
        let values = try? interpretator.getValueTypes(string: encodedString, outputs: outputs)
        result = values?[safe: 0]?.value as? String
        
        //assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result, decodedString)
    }
    
    func testDecodedContractAddressAsAddressType() {
        
        //arrange
        let encodedString = "01000000000000000000000000000000000041a3"
        let decodedString = "16803"
        let type = AbiParameterType.address
        let outputs = [AbiFunctionEntries(name: "", typeString: type.description, type: type)]
        var result: String?
        
        //act
        let values = try? interpretator.getValueTypes(string: encodedString, outputs: outputs)
        let value = values?[safe: 0]
        result = values?[safe: 0]?.value as? String
        
        //assert
        XCTAssertNotNil(value)
        XCTAssertNotNil(result)
        XCTAssertEqual(result, decodedString)
        XCTAssertEqual(value?.type, AbiParameterType.contractAddress)
    }
    
    func testDecodedFullContractAddress() {
        
        //arrange
        let encodedString = "00000000000000000000000001000000000000000000000000000000000041a3"
        let decodedString = "16803"
        let type = AbiParameterType.contractAddress
        let outputs = [AbiFunctionEntries(name: "", typeString: type.description, type: type)]
        var result: String?
        
        //act
        let values = try? interpretator.getValueTypes(string: encodedString, outputs: outputs)
        result = values?[safe: 0]?.value as? String
        
        //assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result, decodedString)
    }
    
    func testDecodeETHContractAddress() {
        
        //arrange
        let encodedString = "000000000000000000000000ca35b7d915458ef540ade6068dfe2f44e8fa733c"
        let decodedString = "0xca35b7d915458ef540ade6068dfe2f44e8fa733c"
        
        let type = AbiParameterType.ethContractAddress
        let outputs = [AbiFunctionEntries(name: "", typeString: type.description, type: type)]
        var result: String?
        
        //act
        let values = try? interpretator.getValueTypes(string: encodedString, outputs: outputs)
        result = values?[safe: 0]?.value as? String
        
        //assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result, decodedString)
    }
    
    func testDecodedNameProperty() {
        
        //arrange
        let encodedString = "000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000036b6b640000000000000000000000000000000000000000000000000000000000"
        let decodedString = "kkd"
        let type = AbiParameterType.string
        let outputs = [AbiFunctionEntries(name: "", typeString: type.description, type: type)]
        var result: String?
        
        //act
        let values = try? interpretator.getValueTypes(string: encodedString, outputs: outputs)
        result = values?[safe: 0]?.value as? String
        
        //assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result, decodedString)
    }
    
    func testDecodedSymbolProperty() {
        
        //arrange
        let encodedString = "000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000036a6b730000000000000000000000000000000000000000000000000000000000"
        let decodedString = "jks"
        let type = AbiParameterType.string
        let outputs = [AbiFunctionEntries(name: "", typeString: type.description, type: type)]
        var result: String?
        
        //act
        let values = try? interpretator.getValueTypes(string: encodedString, outputs: outputs)
        result = values?[safe: 0]?.value as? String
        
        //assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result, decodedString)
    }
    
    func testDecodedDecimalsProperty() {
        
        //arrange
        let encodedString = "0000000000000000000000000000000000000000000000000000000000000063"
        let decodedString = "99"
        let type = AbiParameterType.uint(size: 256)
        let outputs = [AbiFunctionEntries(name: "", typeString: type.description, type: type)]
        var result: String?
        
        //act
        let values = try? interpretator.getValueTypes(string: encodedString, outputs: outputs)
        result = values?[safe: 0]?.value as? String
        
        //assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result, decodedString)
    }
    
    func testDecodeUintAndUint() {
        
        //arrange
        let encodedString = "00000000000000000000000000000000000000000000000000000000000000630000000000000000000000000000000000000000000000000000000000000064"
        let firstDecoded = "99"
        let secondDecoded = "100"
        let firstType = AbiParameterType.uint(size: 256)
        let secondType = AbiParameterType.uint(size: 256)
        let outputs = [AbiFunctionEntries(name: "", typeString: firstType.description, type: firstType), AbiFunctionEntries(name: "", typeString: secondType.description, type: secondType)]
        var firstResult: String?
        var secondResult: String?

        //act
        let values = try? interpretator.getValueTypes(string: encodedString, outputs: outputs)
        firstResult = values?[safe: 0]?.value as? String
        secondResult = values?[safe: 1]?.value as? String
        
        //assert
        XCTAssertNotNil(firstResult)
        XCTAssertNotNil(secondResult)

        XCTAssertEqual(firstResult, firstDecoded)
        XCTAssertEqual(secondResult, secondDecoded)
    }
    
    func testDecodeAddressAndUint() {
        
        //arrange
        let encodedString = "00000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000064"
        let firstDecoded = "18"
        let secondDecoded = "100"
        let firstType = AbiParameterType.address
        let secondType = AbiParameterType.uint(size: 256)
        let outputs = [AbiFunctionEntries(name: "", typeString: firstType.description, type: firstType), AbiFunctionEntries(name: "", typeString: secondType.description, type: secondType)]
        var firstResult: String?
        var secondResult: String?
        
        //act
        let values = try? interpretator.getValueTypes(string: encodedString, outputs: outputs)
        firstResult = values?[safe: 0]?.value as? String
        secondResult = values?[safe: 1]?.value as? String
        
        //assert
        XCTAssertNotNil(firstResult)
        XCTAssertNotNil(secondResult)
        
        XCTAssertEqual(firstResult, firstDecoded)
        XCTAssertEqual(secondResult, secondDecoded)
    }
    
    func testDecodeUint256AndUint256AndString() {
        
        
        //arrange
        let encodedString = "000000000000000000000000000000000000000000000000000000000000007b00000000000000000000000000000000000000000000000000000000000001c800000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000023746865717569636b62726f776e666f786a756d70736f7665727468656c617a79646f670000000000000000000000000000000000000000000000000000000000"
        
        let outputs = ["123", "456", "thequickbrownfoxjumpsoverthelazydog"]
        
        let uintType = AbiParameterType.uint(size: 256)
        let stringType = AbiParameterType.string
        
        let outputTypes = [AbiFunctionEntries(name: "", typeString: uintType.description, type: uintType),
                           AbiFunctionEntries(name: "", typeString: uintType.description, type: uintType),
                           AbiFunctionEntries(name: "", typeString: stringType.description, type: stringType)]
        
        //act
        let outputModels = try? interpretator.getValueTypes(string: encodedString, outputs: outputTypes)
        let outputValues = outputModels?.compactMap { $0.value as? String }
        
        //assert
        XCTAssertNotNil(outputValues)
        XCTAssertEqual(outputValues, outputs)
    }
    
    func testDecodeUint256AndUint256AndStringAndString() {
        
        //arrange
        let encodedString = "000000000000000000000000000000000000000000000000000000000000007b00000000000000000000000000000000000000000000000000000000000001c8000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000000000000000000000000000023746865717569636b62726f776e666f786a756d70736f7665727468656c617a79646f670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e73686573656c6c737365617368656c6c736f6e74686573656173686f72650000"
        
        let outputs = ["123", "456", "thequickbrownfoxjumpsoverthelazydog", "shesellsseashellsontheseashore"]
        
        let uintType = AbiParameterType.uint(size: 256)
        let stringType = AbiParameterType.string
        
        let outputTypes = [AbiFunctionEntries(name: "", typeString: uintType.description, type: uintType),
                           AbiFunctionEntries(name: "", typeString: uintType.description, type: uintType),
                           AbiFunctionEntries(name: "", typeString: stringType.description, type: stringType),
                           AbiFunctionEntries(name: "", typeString: stringType.description, type: stringType)]
        
        //act
        let outputModels = try? interpretator.getValueTypes(string: encodedString, outputs: outputTypes)
        let outputValues = outputModels?.compactMap { $0.value as? String }
        
        //assert
        XCTAssertNotNil(outputValues)
        XCTAssertEqual(outputValues, outputs)
    }
    
    func testDecodeBoolAndStringAndStringAndUint8AndBool() {
        
        //arrange
        let encodedString = "000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e000000000000000000000000000000000000000000000000000000000000000ff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002736400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000036173640000000000000000000000000000000000000000000000000000000000"
        
        let outputs = ["1", "sd", "asd", "255", "0"]
        
        let uintType = AbiParameterType.uint(size: 256)
        let stringType = AbiParameterType.string
        let boolType = AbiParameterType.bool

        
        let outputTypes = [AbiFunctionEntries(name: "", typeString: boolType.description, type: boolType),
                           AbiFunctionEntries(name: "", typeString: stringType.description, type: stringType),
                           AbiFunctionEntries(name: "", typeString: stringType.description, type: stringType),
                           AbiFunctionEntries(name: "", typeString: uintType.description, type: uintType),
                           AbiFunctionEntries(name: "", typeString: boolType.description, type: boolType)]
        
        //act
        let outputModels = try? interpretator.getValueTypes(string: encodedString, outputs: outputTypes)
        let outputValues = outputModels?.compactMap { $0.value as? String }
        
        //assert
        XCTAssertNotNil(outputValues)
        XCTAssertEqual(outputValues, outputs)
    }
    
    func testDecodeAddressAndUint256AndUint256AndStringAndString() {
        
        //arrange
        let encodedString = "0000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000007b00000000000000000000000000000000000000000000000000000000000001c800000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000023746865717569636b62726f776e666f786a756d70736f7665727468656c617a79646f670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001e73686573656c6c737365617368656c6c736f6e74686573656173686f72650000"
        
        let outputs = ["18", "123", "456", "thequickbrownfoxjumpsoverthelazydog", "shesellsseashellsontheseashore"]
        
        let uintType = AbiParameterType.uint(size: 256)
        let stringType = AbiParameterType.string
        let addressType = AbiParameterType.address
        
        
        let outputTypes = [AbiFunctionEntries(name: "", typeString: addressType.description, type: addressType),
                           AbiFunctionEntries(name: "", typeString: uintType.description, type: uintType),
                           AbiFunctionEntries(name: "", typeString: uintType.description, type: uintType),
                           AbiFunctionEntries(name: "", typeString: stringType.description, type: stringType),
                           AbiFunctionEntries(name: "", typeString: stringType.description, type: stringType)]
        
        //act
        let outputModels = try? interpretator.getValueTypes(string: encodedString, outputs: outputTypes)
        let outputValues = outputModels?.compactMap { $0.value as? String }
        
        //assert
        XCTAssertNotNil(outputValues)
        XCTAssertEqual(outputValues, outputs)
    }
    
    func testDecodeEtherExampleBytesAndBoolAndDynamicArrayOfUints() {
        
        //arrange
        let encodedString = "0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000464617665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003"
        
        let outputs = ["dave", "1", "[1,2,3]"]
        
        let bytesType = AbiParameterType.bytes
        let boolType = AbiParameterType.bool
        let dynamicArrayOfUintType = AbiParameterType.dynamicArrayOfUint
        
        
        let outputTypes = [AbiFunctionEntries(name: "", typeString: bytesType.description, type: bytesType),
                           AbiFunctionEntries(name: "", typeString: boolType.description, type: boolType),
                           AbiFunctionEntries(name: "", typeString: dynamicArrayOfUintType.description, type: dynamicArrayOfUintType)]
        
        //act
        let outputModels = try? interpretator.getValueTypes(string: encodedString, outputs: outputTypes)
        let outputValues = outputModels?.compactMap { $0.value as? String }
        
        //assert
        XCTAssertNotNil(outputValues)
        XCTAssertEqual(outputValues, outputs)
    }
    
    func testDecodeEtherExampleUintArrayOfIntFixedBytesAndBytes() {
        
        //arrange
        let encodedString = "00000000000000000000000000000000000000000000000000000000000001230000000000000000000000000000000000000000000000000000000000000080313233343536373839300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000004560000000000000000000000000000000000000000000000000000000000000789000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000"
        
        let outputs = ["291", "[1110,1929]", "1234567890", "Hello, world!"]
        
        let bytesType = AbiParameterType.bytes
        let fixedBytesType = AbiParameterType.fixedBytes(size: 10)
        let dynamicArrayOfUintType = AbiParameterType.dynamicArrayOfUint
        let uintType = AbiParameterType.uint(size: 256)

        
        let outputTypes = [AbiFunctionEntries(name: "", typeString: uintType.description, type: uintType),
                           AbiFunctionEntries(name: "", typeString: dynamicArrayOfUintType.description, type: dynamicArrayOfUintType),
                           AbiFunctionEntries(name: "", typeString: fixedBytesType.description, type: fixedBytesType),
                           AbiFunctionEntries(name: "", typeString: bytesType.description, type: bytesType)]
        
        //act
        let outputModels = try? interpretator.getValueTypes(string: encodedString, outputs: outputTypes)
        let outputValues = outputModels?.compactMap { $0.value as? String }
        
        //assert
        XCTAssertNotNil(outputValues)
        XCTAssertEqual(outputValues, outputs)
    }
    
    func testDecodeEtherExampleUintArrayOfIntFixedBytesAndBytes2() {
        
        //arrange
        let encodedString = "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000080313233343536373839300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000"
        
        let outputs = ["1", "[2,3]", "1234567890", "Hello, world!"]
        
        let bytesType = AbiParameterType.bytes
        let fixedBytesType = AbiParameterType.fixedBytes(size: 10)
        let dynamicArrayOfUintType = AbiParameterType.dynamicArrayOfUint
        let uintType = AbiParameterType.uint(size: 256)
        
        
        let outputTypes = [AbiFunctionEntries(name: "", typeString: uintType.description, type: uintType),
                           AbiFunctionEntries(name: "", typeString: dynamicArrayOfUintType.description, type: dynamicArrayOfUintType),
                           AbiFunctionEntries(name: "", typeString: fixedBytesType.description, type: fixedBytesType),
                           AbiFunctionEntries(name: "", typeString: bytesType.description, type: bytesType)]
        
        //act
        let outputModels = try? interpretator.getValueTypes(string: encodedString, outputs: outputTypes)
        let outputValues = outputModels?.compactMap { $0.value as? String }
        
        //assert
        XCTAssertNotNil(outputValues)
        XCTAssertEqual(outputValues, outputs)
    }
    
    func testDecodeUintAndDynamicArrayOfAddressesAndBytes10AndBytes() {
        
        //arrange
        let encodedString = "00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000080313233343536373839300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000120000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000"
        
        let outputs = ["1", "[18,18]", "1234567890", "Hello, world!"]
        
        let bytesType = AbiParameterType.bytes
        let fixedBytesType = AbiParameterType.fixedBytes(size: 10)
        let dynamicArrayOfUintType = AbiParameterType.dynamicArrayOfUint
        let uintType = AbiParameterType.uint(size: 256)
        
        
        let outputTypes = [AbiFunctionEntries(name: "", typeString: uintType.description, type: uintType),
                           AbiFunctionEntries(name: "", typeString: dynamicArrayOfUintType.description, type: dynamicArrayOfUintType),
                           AbiFunctionEntries(name: "", typeString: fixedBytesType.description, type: fixedBytesType),
                           AbiFunctionEntries(name: "", typeString: bytesType.description, type: bytesType)]
        
        //act
        let outputModels = try? interpretator.getValueTypes(string: encodedString, outputs: outputTypes)
        let outputValues = outputModels?.compactMap { $0.value as? String }
        
        //assert
        XCTAssertNotNil(outputValues)
        XCTAssertEqual(outputValues, outputs)
    }
    
    
}
