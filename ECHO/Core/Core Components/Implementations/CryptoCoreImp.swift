//
//  CryptoCoreImp.swift
//  EchoCons
//
//  Created by Fedorenko Nikita on 20.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

class CryptoCoreImp: CryptoCoreComponent {
    
    func generatePublicKey(withPrivateKey privateKeyData: Data, compression isCompression: Bool) -> Data {
        return Crypto.generatePublicKey(data: privateKeyData, compressed: isCompression)
    }
    
    func sha256(_ data: Data) -> Data {
        return CryptoHash.sha256(data)
    }
    
    func ripemd160(_ data: Data) -> Data {
        return CryptoHash.ripemd160(data)
    }
    
    func sign(_ hash: Data, privateKey: Data) throws -> Data {
        return try Crypto.sign(hash, privateKey: privateKey)
    }
    
    func encryptMessage(privateKey: Data, publicKey: Data, nonce: String, message: String) -> Data {
        return Crypto.encryptMessage(privateKey: privateKey, publicKey: publicKey, nonce: nonce, message: message)
    }
    
    func decryptMessage(privateKey: Data, publicKey: Data, nonce: String, message: String) -> Data {
        return Crypto.decryptMessage(privateKey: privateKey, publicKey: publicKey, nonce: nonce, message: message)
    }
    
    func getPublicKeyFromAddress(_ address: String, networkPrefix: String) -> Data {
        return Crypto.getPublicKeyFromAddress(address, networkPrefix: networkPrefix)
    }
}
