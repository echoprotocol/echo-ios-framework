//
//  AddressKeysContainerTests.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 27.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class AddressKeysContainerTests: XCTestCase {

    func testExample() {
        //arrange
        let name = "vsharaev"
        let password = "vsharaev1"
        let cryptoCore = CryptoCoreImp()

        // We use active seed for all private keys for every role
        // If you want to use different seed change params into AddressKeysContainer
        
        //act
        let keychainActive = ECHOKeychainEd25519(name: name, password: password, type: .active, core: cryptoCore)
        let edcaKeychainActive = ECHOKeychainSecp256k1(name: name, password: password, type: .active, core: cryptoCore)
        let keychainEchorand = ECHOKeychainEd25519(name: name, password: password, type: .echorand, core: cryptoCore)
        let container = AddressKeysContainer(login: name, password: password, core: cryptoCore)
        
        //assert
        XCTAssertEqual(keychainActive?.publicAddress(), container?.activeKeychain.publicAddress())
        XCTAssertEqual(edcaKeychainActive?.publicAddress(), container?.memoKeychain.publicAddress())
        XCTAssertEqual(keychainEchorand?.publicAddress(), container?.echorandKeychain.publicAddress())
    }    
}
