//
//  ECHOKeychainTest.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 27.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import XCTest
@testable import EchoFramework

class ECHOKeychainTest: XCTestCase {
    
    func testEDCAKeychain() {
        
        //arrange
        let wif = "5KjC8BiryoxUNz3dEY2ZWQK5ssmD84JgRGemVWwxfNgiPoxcaVa"
        let cryptoCore = CryptoCoreImp()
        let keychain = ECHOKeychainEd25519(wif: wif, core: cryptoCore)
        
        //act
        let publicKey = keychain?.publicAddress()
        
        //assert
        XCTAssertEqual(publicKey, "CuS6J2FDbXQNVLa2a2D7XM1nESghyrSgvmKNLcyKiUN3")
    }
    
    func testGenerateRandomWIF() {
        
        //arrange
        let cryptoCore = CryptoCoreImp()
        
        //act
        let first = ECHOKeychainEd25519(core: cryptoCore).wif()
        let second = ECHOKeychainEd25519(core: cryptoCore).wif()
        let third = ECHOKeychainEd25519(core: cryptoCore).wif()
        
        //assert
        XCTAssertNotEqual(first, second)
        XCTAssertNotEqual(first, third)
        XCTAssertNotEqual(second, third)
    }
}
