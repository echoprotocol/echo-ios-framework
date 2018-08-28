//
//  CryptoCoreComponentTests.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 27.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class CryptoCoreComponentTests: XCTestCase {
    
    let cryptoCore = CryptoCoreImp()
    
    func testGeneratePublicKey() {
        
        //arrange
        let privateKeyData = Data(hex: "4d06f9499e922b268bf868db6ea7f185f142a7eeb89aa2db98c074ea16dc2b4a")!
        
        //act
        let publicKey = cryptoCore.generatePublicKey(withPrivateKey: privateKeyData, compression: true)
        
        //assert
        XCTAssertEqual(publicKey.hex, "030209946a0a9e0e4aef020f062c963e33c4f3dc192df0599f74acb87192caa066")
    }
    
    func testRIEPMD160() {
        
        //arrange
        let data = Data(hex:  "030209946a0a9e0e4aef020f062c963e33c4f3dc192df0599f74acb87192caa066")!
        
        //act
        let hashed = cryptoCore.ripemd160(data)
        
        //assert
        XCTAssertEqual(hashed.hex, "8db955429d4b2c77e68c87118623d28a90b39e77")
    }
    
    func testSHA256() {
        
        //arrange
        let data = Data(hex:  "64696d61316f776e657250354a387044797a7a6e4d6d456469424364674237564b744d427578773565344d414a456f337366556278634d")!
        
        //act
        let hashed = cryptoCore.sha256(data)
        
        //assert
        XCTAssertEqual(hashed.hex, "4d06f9499e922b268bf868db6ea7f185f142a7eeb89aa2db98c074ea16dc2b4a")
    }
}
