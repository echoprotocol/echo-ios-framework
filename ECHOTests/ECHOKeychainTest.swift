//
//  ECHOKeychainTest.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 27.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class ECHOKeychainTest: XCTestCase {
    
    func testOwnerKeychain() {
        //arrange
        let name = "dima1"
        let password = "P5J8pDyzznMmEdiBCdgB7VKtMBuxw5e4MAJEo3sfUbxcM"
        let cryptoCore = CryptoCoreImp()
        let keychain = ECHOKeychainSecp256k1(name: name, password: password, type: .owner, core: cryptoCore)
        
        //act
        let publicKey = keychain?.publicAddress()
        
        //assert
        XCTAssertEqual(publicKey, "6r8aCcMXqYbV1hCVh9ny7Xx3eXCqiaR1wjPH1Atra4JyLDL9mK")
    }
    
    func testActiveKeychain() {
        //arrange
        let name = "dima1"
        let password = "P5J8pDyzznMmEdiBCdgB7VKtMBuxw5e4MAJEo3sfUbxcM"
        let cryptoCore = CryptoCoreImp()
        let keychain = ECHOKeychainSecp256k1(name: name, password: password, type: .active, core: cryptoCore)
        
        //act
        let publicKey = keychain?.publicAddress()
        
        //assert
        XCTAssertEqual(publicKey, "5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9")
    }
    
    func testMemoKeychain() {
        //arrange
        let name = "dima1"
        let password = "P5J8pDyzznMmEdiBCdgB7VKtMBuxw5e4MAJEo3sfUbxcM"
        let cryptoCore = CryptoCoreImp()
        let keychain = ECHOKeychainSecp256k1(name: name, password: password, type: .memo, core: cryptoCore)
        
        //act
        let publicKey = keychain?.publicAddress()
        
        //assert
        XCTAssertEqual(publicKey, "4yHX6vPgQjiYn1SsVQrNoRSNSpX5BVKMboWKsSagASw4f9mzeG")
    }
    
    func testEmptyKeychain() {
        //arrange
        let name = ""
        let password = ""
        let cryptoCore = CryptoCoreImp()
        let keychain = ECHOKeychainSecp256k1(name: name, password: password, type: .memo, core: cryptoCore)
        
        //act
        let publicKey = keychain?.publicAddress()
        
        //assert
        XCTAssertEqual(publicKey, "6RmL1gJckuVKC4PUa8j1GxNpJXaDbjFCyo1ijqxHq3jSbozdAs")
    }
}
