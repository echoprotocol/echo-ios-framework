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
    
    func testEncryptMessage() {
        
        //arrange
        let privateKey = Data(hex: "f33b293c58b55e7a34878d5e2fcc5b82624bef424a0ce282be10069a4a60eae5")!
        let publicKey = Data(hex: "028d4927dde3607d75f09532ea825313dba15411f1c6f7ea355ec5265e8ea39fa1")!
        let message = "Hello World!"
        let nonce = "0"
        
        //act
        let encryptedMessage = cryptoCore.encryptMessage(privateKey: privateKey, publicKey: publicKey, nonce: nonce, message: message)
        
        //assert
        XCTAssertEqual(encryptedMessage.hex, "eeaaf3119b3342e2c16610ba661ce5cca0ab82c3fd0656b2712ff1016d1f0fdf")
    }
    
    func testDecryptMessage() {
        
        //arrange
        let privateKey = Data(hex: "f33b293c58b55e7a34878d5e2fcc5b82624bef424a0ce282be10069a4a60eae5")!
        let publicKey = Data(hex: "028d4927dde3607d75f09532ea825313dba15411f1c6f7ea355ec5265e8ea39fa1")!
        let message = Data(hex: "eeaaf3119b3342e2c16610ba661ce5cca0ab82c3fd0656b2712ff1016d1f0fdf")!
        let nonce = "0"
        
        //act
        let decryptedMessage = cryptoCore.decryptMessage(privateKey: privateKey, publicKey: publicKey, nonce: nonce, message: message)
        
        //assert
        XCTAssertEqual(decryptedMessage, "Hello World!")
    }
    
    func testEncryptThenDecryptMessage() {
        
        //arrange
        let privateKey = Data(hex: "f33b293c58b55e7a34878d5e2fcc5b82624bef424a0ce282be10069a4a60eae5")!
        let publicKey = Data(hex: "028d4927dde3607d75f09532ea825313dba15411f1c6f7ea355ec5265e8ea39fa1")!
        let message = "Hello World!"
        let nonce = "0"
        
        //act
        let encryptedMessage = cryptoCore.encryptMessage(privateKey: privateKey, publicKey: publicKey, nonce: nonce, message: message)
        let decryptedMessage = cryptoCore.decryptMessage(privateKey: privateKey, publicKey: publicKey, nonce: nonce, message: encryptedMessage)
        
        //assert
        XCTAssertEqual(message, decryptedMessage)
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
}
