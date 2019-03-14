//
//  CryptoCoreImp.swift
//  EchoCons
//
//  Created by Fedorenko Nikita on 20.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Implementation of [CryptoCoreComponent](CryptoCoreComponent)
*/
final public class CryptoCoreImp: CryptoCoreComponent {
    
    public init() { }
    
    public func sha256(_ data: Data) -> Data {
        return CryptoHash.sha256(data)
    }
    
    public func ripemd160(_ data: Data) -> Data {
        return CryptoHash.ripemd160(data)
    }
    
    public func keccak256(_ data: Data) -> Data {
        return Data(bytes: SHA3(variant: .keccak256).calculate(for: data.bytes))
    }
    
    public func sign(_ hash: Data, privateKey: Data) throws -> Data {
        return try Crypto.sign(hash, privateKey: privateKey)
    }
    
    public func signByEd25519(_ hash: Data, privateKey: Data) -> Data {
        return Crypto.signByEd25519(hash, privateKey: privateKey)
    }
    
    public func encryptMessage(privateKey: Data, publicKey: Data, nonce: String, message: String) -> Data {
        return Crypto.encryptMessage(privateKey: privateKey, publicKey: publicKey, nonce: nonce, message: message)
    }
    
    public func decryptMessage(privateKey: Data, publicKey: Data, nonce: String, message: Data) -> String {
        return Crypto.decryptMessage(privateKey: privateKey, publicKey: publicKey, nonce: nonce, message: message)
    }
    
    public func getPublicKeyFromAddress(_ address: String, networkPrefix: String) -> Data {
        return Crypto.getPublicKeyFromAddress(address, networkPrefix: networkPrefix)
    }
    
    public func generatePublicKey(withPrivateKey privateKeyData: Data, compression isCompression: Bool) -> Data {
        return Crypto.generatePublicKey(data: privateKeyData, compressed: isCompression)
    }
    
    public func generatePublicEd25519Key(withPrivateKey privateKeyData: Data) -> Data {
        return Crypto.generatePublicEd25519Key(data: privateKeyData)
    }
    
    public func getPrivateKeyFromWIF(_ wif: String) -> Data? {
        return Crypto.getPrivateKeyFromWIF(wif)
    }
    
    public func getWIFFromPrivateKey(_ privateKey: Data) -> String {
        return Crypto.getWIFFromPrivateKey(privateKey)
    }
}
