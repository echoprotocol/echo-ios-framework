//
//  BTCAddressValidatorTests.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 28.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class BTCAddressValidatorTests: XCTestCase {
    
    let validator = BTCAddressValidator(cryptoCore: CryptoCoreImp())
    
    func testCheckAddress() {
        
        //arrange
        let address1 = "2N4zCdEbxGB67NnLoKWpp4dBQ21jDLsDoWf"
        //assert
        XCTAssertTrue(validator.isValidBTCAddress(address1))
        
        //arrange
        let address2 = "38zao9WscyePY9PB5mB759dJbBGK9mbYeN"
        //assert
        XCTAssertTrue(validator.isValidBTCAddress(address2))
        
        //arrange
        let address3 = "1CrvVjSEMhNueA2EB8prsaR5zoVxNZYeHP"
        //assert
        XCTAssertTrue(validator.isValidBTCAddress(address3))
        
        //arrange
        let address4 = "bc1q6t47j3c9mhdrdtuc2x553fl0thegn4gnqhdvt5"
        //assert
        XCTAssertTrue(!validator.isValidBTCAddress(address4))
        
        //arrange
        let address5 = "2NBZVAVjXxqww82hznH9uypV1xBR6TfLKzZ"
        //assert
        XCTAssertTrue(validator.isValidBTCAddress(address5))
        
        //arrange
        let address6 = "tb1q3axk7z7deyf33dvpm0a9gt762t3hujycta5dct"
        //assert
        XCTAssertTrue(!validator.isValidBTCAddress(address6))
        
        
        //arrange
        let address7 = "N2BZVAVjXxqww82hznH9uypV1xBR6TfLKzZ"
        //assert
        XCTAssertTrue(!validator.isValidBTCAddress(address7))
    }
}

