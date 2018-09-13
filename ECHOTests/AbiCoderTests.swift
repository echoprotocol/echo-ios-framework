//
//  AbiCoderTests.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 13.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class AbiCoderTests: XCTestCase {
    
    var coder: AbiCoder = AbiCoderImp(argumentCoder: AbiArgumentCoderImp())

    func testEncodeTotalSupplyProperty() {
        
        //arrange
        let function = "totalSupply"
        let resultHash = "18160ddd"

        //act
        let hash = try? coder.getStringHash(funcName: function)
        
        //assert
        XCTAssertNotNil(hash)
        XCTAssertEqual(hash, resultHash)
    }
    
    func testEncodeNameProperty() {
        
        //arrange
        let function = "name"
        let resultHash = "06fdde03"
        
        //act
        let hash = try? coder.getStringHash(funcName: function)
        
        //assert
        XCTAssertNotNil(hash)
        XCTAssertEqual(hash, resultHash)
    }
    
    func testEncodeDecimalsProperty() {
        
        //arrange
        let function = "decimals"
        let resultHash = "313ce567"
        
        //act
        let hash = try? coder.getStringHash(funcName: function)
        
        //assert
        XCTAssertNotNil(hash)
        XCTAssertEqual(hash, resultHash)
    }
    
    func testEncodeSymbolsProperty() {
        
        //arrange
        let function = "symbol"
        let resultHash = "95d89b41"
        
        //act
        let hash = try? coder.getStringHash(funcName: function)
        
        //assert
        XCTAssertNotNil(hash)
        XCTAssertEqual(hash, resultHash)
    }
    
    func testEncodeTotalSupplyFunctionWithoutParam() {
        
        //arrange
        let function = "totalSupply"
        let resultHash = "18160ddd"
        let inputs = [AbiTypeValueInputModel]()
        //act
        let hash = try? coder.getStringHash(funcName: function, param: inputs)
        
        //assert
        XCTAssertNotNil(hash)
        XCTAssertEqual(hash, resultHash)
    }
    
    
}
