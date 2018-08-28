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
        let name = "dima1"
        let password = "P5J8pDyzznMmEdiBCdgB7VKtMBuxw5e4MAJEo3sfUbxcM"
        let cryptoCore = CryptoCoreImp()

        //act
        let keychainOwner = ECHOKeychain(name: name, password: password, type: .owner, core: cryptoCore)
        let keychainActive = ECHOKeychain(name: name, password: password, type: .active, core: cryptoCore)
        let keychainMemo = ECHOKeychain(name: name, password: password, type: .memo, core: cryptoCore)
        let container = AddressKeysContainer(login: name, password: password, core: cryptoCore)
        
        //assert
        XCTAssertEqual(keychainOwner?.publicAddress(), container?.ownerKeychain.publicAddress())
        XCTAssertEqual(keychainActive?.publicAddress(), container?.activeKeychain.publicAddress())
        XCTAssertEqual(keychainMemo?.publicAddress(), container?.memoKeychain.publicAddress())
    }    
}
