//
//  Crypto.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 7.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import ECHO.Private

/// Helper class for cryptographic algorithms.
final class Crypto {

    /// Returns private key from wif
    ///
    /// - Parameters:
    ///   - wif: Private key in WIF format
    /// - Returns: 32-byte private key. If any error find, will return nil
    public static func getPrivateKeyFromWIF(_ wif: String) -> Data? {
        
        var bytes = Base58.decode(wif)
        
        if bytes.count < 4 {
            return nil
        }
        
        let checksum = bytes.subdata(in: bytes.count-4..<bytes.count)
        bytes.removeSubrange(bytes.count-4..<bytes.count)
        let generatedChecksum = Crypto.generateChecksumForData(bytes)
        
        if checksum != generatedChecksum {
            return nil
        }
        
        let firstByte = bytes.removeFirst()
        
        if firstByte != 0x80 {
            return nil
        }
        
        if bytes.count != 32 {
            return nil
        }
        
        return bytes
    }
    
    /// Returns private key in presentedd in WIF format
    ///
    /// - Parameters:
    ///   - privateKey: 32-byte private key
    /// - Returns: Private key in presentedd in WIF format
    public static func getWIFFromPrivateKey(_ privateKey: Data) -> String {
        
        var data = Data(privateKey.bytes)
        
        data.insert(0x80, at: 0)
        
        let checksum = generateChecksumForData(data)
        
        data.append(checksum)
        
        let base58String = Base58.encode(data)
        
        return base58String
    }
    
    // Returns checksum for data
    ///
    /// - Parameters:
    ///   - data: Data for checksum generation
    /// - Returns: 4 bytes of checksum
    private static func generateChecksumForData(_ data: Data) -> Data {
        
        let firstSHA256 = CryptoHash.sha256(data)
        let secondSHA256 = CryptoHash.sha256(firstSHA256)
        
        return secondSHA256[0...3]
    }
    
    /// Generates public key from address string with network prefix
    ///
    /// - Parameters:
    ///   - address: address string with network prefix
    ///   - networkPrefix: string value of network prefix
    /// - Returns: public key data value
    public static func getPublicKeyFromAddress(_ address: String, networkPrefix: String) -> Data {
        
        var address = address
        if let range = address.range(of: networkPrefix) {
            address.removeSubrange(range)
        }
        
        var data = Base58.decode(address)
        data.removeLast(4)
        
        return data
    }
    
    /// Generates rendom private key using ed25519 elliptic curve math
    ///
    /// - Returns: 32-byte private key
    public static func generateRandomEd25519PrivateKey() -> Data {
        
        return Ed25519.generateRandomPrivateKey()
    }
    
    /// Generates public key from private key using ed25519 elliptic curve math
    ///
    /// - Parameters:
    ///   - data: 32-byte private key
    /// - Returns: 32-byte key
    public static func generatePublicEd25519Key(data: Data) -> Data {
        
        return Ed25519.generatePublicKey(withPrivateKey: data)
    }
    
    /// Signs hash with private key using ed25519 elliptic curve math
    ///
    /// - Parameters:
    ///   - hash: Hash of a message
    ///   - privateKey: 32-byte private key
    /// - Returns: 64-byte signature of the hash data
    public static func signByEd25519(_ hash: Data, privateKey: Data) -> Data {
        
        return Ed25519.sign(hash, privateKey: privateKey);
    }
}
