//
//  WIFValidatorTests.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 11/07/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class WIFValidatorTests: XCTestCase {
    
    let validator = WIFValidator(cryptoCore: CryptoCoreImp())
    
    func testCheckWIF() {
        
        //arrange
        let validWIF = "5JoFZeMjsQRfg3DykoXynYaLq5BGtPq7CEofnsiURXudAbDjPqy"
        XCTAssertTrue(validator.isValidWIF(validWIF))
        
        //arrange
        let invalidLowerCaseWIF = "5JoFZeMjsQRfg3DykoXynYaLq5BGtPq7CEofnsiURXudAbDjPqy".lowercased()
        XCTAssertTrue(!validator.isValidWIF(invalidLowerCaseWIF))
        
        //arrange
        let invalidUpperCaseWIF = "5JoFZeMjsQRfg3DykoXynYaLq5BGtPq7CEofnsiURXudAbDjPqy".uppercased()
        XCTAssertTrue(!validator.isValidWIF(invalidUpperCaseWIF))
        
        //arrange
        let invalidWIF = "5JoFZeMjsQRfg3DykoXynYaLq5BGtPq7CEofnsiURXudAbDjPqyasdf"
        XCTAssertTrue(!validator.isValidWIF(invalidWIF))
        
        //arrange
        let invalidChacksumWIF = "5JoFZeMjsQRfg3DykoXynYaLq5BGtPq7CEofnsiURXudAbDjaqy"
        XCTAssertTrue(!validator.isValidWIF(invalidChacksumWIF))
        
        //arrange
        let invalidFirstByteWIF = "4JoFZeMjsQRfg3DykoXynYaLq5BGtPq7CEofnsiURXudAbDjPqy"
        XCTAssertTrue(!validator.isValidWIF(invalidFirstByteWIF))
    }
}
