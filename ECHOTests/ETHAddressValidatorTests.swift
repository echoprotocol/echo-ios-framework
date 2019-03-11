//
//  ETHAddressValidatorTests.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 11/03/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class ETHAddressValidatorTests: XCTestCase {
    
    let validator = ETHAddressValidator(cryptoCore: CryptoCoreImp())
    
    func testCheckAddress() {
        
        //arrange
        let validLowerCaseAddress = "0x3de8c14c8e7a956f5cc4d82beff749ee65fdc358";
        //assert
        XCTAssertTrue(validator.isValidETHAddress(validLowerCaseAddress));
        
        //arrange
        let validChecksumAddress = "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359";
        //assert
        XCTAssertTrue(validator.isValidETHAddress(validChecksumAddress));
        
        //arrange
        let invalidLengthAddress = "0x3de8c14c8e7a956f5cc4d82beff749ee65bac35"; 
        //assert
        XCTAssertFalse(validator.isValidETHAddress(invalidLengthAddress));
        
        //arrange
        let invalidChecksumAddress = "0x3de8c14c8E7a956f5cc4d82beff749ee65fdc358";
        //assert
        XCTAssertFalse(validator.isValidETHAddress(invalidChecksumAddress));
    }
}
