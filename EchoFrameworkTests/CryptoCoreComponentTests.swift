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
    
    func testEd25519PublicKeyGeneration() {
        
        //arrange
        let privateKeyData = Data(hex: "c5aa8df43f9f837bedb7442f31dcb7b166d38535076f094b85ce3a2e0b4458f7")!
        
        //act
        let publicKey = cryptoCore.generatePublicEd25519Key(withPrivateKey: privateKeyData)
        
        //assert
        XCTAssertEqual(publicKey.hex, "a08fd46ee534e62d08e577a84a28601903d424bdf288be45644ece293672943e")
    }
    
    func testEd25519SignText() {

        //arrange
        let data = Data(hex: "746573746d7367")!
        let privateKeyData = Data(hex: "c5aa8df43f9f837bedb7442f31dcb7b166d38535076f094b85ce3a2e0b4458f7")!

        //act
        let signature = cryptoCore.signByEd25519(data, privateKey: privateKeyData)
        //assert
        XCTAssertEqual(signature.hex, "f457ae1fd4f4ff52ea09f807bdda0eddfeb05467c2c24df1009b9d63ce6dab4fd391395be4d41540f582d937c4accea360d2be13ff7e17a084d1016aeb56f308")
    }
    
    func testPrivateKeyFromWIF() {
        
        //arrange
        let wifString = "5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ"
        let privString = "0c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d"
        
        //act
        let privData = cryptoCore.getPrivateKeyFromWIF(wifString)
        
        //assert
        XCTAssertEqual(privData?.hex, privString)
    }
    
    func testWifFromPrivateKey() {
        
        //arrange
        let wifString = "5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ"
        let privatekey = Data(hex: "0c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d")!
        
        //act
        let wif = cryptoCore.getWIFFromPrivateKey(privatekey)
        
        //assert
        XCTAssertEqual(wif, wifString)
    }
    
    func testPrivateKeyFromWIFFailChecksum() {
        
        //arrange
        let wifString = "5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTA"
        
        //act
        let privData = cryptoCore.getPrivateKeyFromWIF(wifString)
        
        //assert
        XCTAssertNil(privData)
    }
    
    func testPrivateKeyFromWIFFailBytesCount() {
        
        //arrange
        let wifString = "5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4djvhTVqvbTLvyTJ"
        
        //act
        let privData = cryptoCore.getPrivateKeyFromWIF(wifString)
        
        //assert
        XCTAssertNil(privData)
    }
    
    func testPrivateKeyFromWIFFailFirstByte() {
        
        //arrange
        let wifString = "25ueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ"
        
        //act
        let privData = cryptoCore.getPrivateKeyFromWIF(wifString)
        
        //assert
        XCTAssertNil(privData)
    }
}
