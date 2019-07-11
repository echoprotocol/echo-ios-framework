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
public protocol CryptoCoreComponent: class {
    
    func getPublicKeyFromAddress(_ address: String, networkPrefix: String) -> Data
    
    func getPrivateKeyFromWIF(_ wif: String) -> Data?
    func getWIFFromPrivateKey(_ privateKey: Data) -> String
    
    func generateRandomEd25519PrivateKey() -> Data
    func generatePublicEd25519Key(withPrivateKey privateKeyData: Data) -> Data
    func signByEd25519(_ hash: Data, privateKey: Data) -> Data
    
    func sha256(_ data: Data) -> Data
    func ripemd160(_ data: Data) -> Data
    func keccak256(_ data: Data) -> Data
}
