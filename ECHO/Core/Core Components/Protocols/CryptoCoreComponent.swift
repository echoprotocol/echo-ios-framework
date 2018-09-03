//
//  CryptoCoreComponent.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 12.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
     The interface of the class that encompasses all cryptographic functions
 */
public protocol CryptoCoreComponent {
    func getPublicKeyFromAddress(_ address: String, networkPrefix: String) -> Data
    func generatePublicKey(withPrivateKey privateKeyData: Data, compression isCompression: Bool) -> Data
    func sha256(_ data: Data) -> Data
    func ripemd160(_ data: Data) -> Data
    func sign(_ hash: Data, privateKey: Data) throws -> Data
    func encryptMessage(privateKey: Data, publicKey: Data, nonce: String, message: String) -> Data
    func decryptMessage(privateKey: Data, publicKey: Data, nonce: String, message: Data) -> String
}
