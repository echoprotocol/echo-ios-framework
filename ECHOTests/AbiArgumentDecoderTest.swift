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
}
