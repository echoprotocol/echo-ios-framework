import ECHO.Private
import secp256k1

/// Helper class for cryptographic algorithms.
final class Crypto {

    /// Generates public key from private key using secp256k1 elliptic curve math
    ///
    /// - Parameters:
    ///   - data: private key
    ///   - compressed: whether public key should be compressed
    /// - Returns: 65-byte key if not compressed, otherwise 33-byte public key.
    public static func generatePublicKey(data: Data, compressed: Bool) -> Data {
        return Secp256k1.generatePublicKey(withPrivateKey: data, compression: compressed)
    }
    
    /// Signs hash with private key
    ///
    /// - Parameters:
    ///   - hash: Hash of a message (32-byte data = 256-bit hash)
    ///   - privateKey: serialized private key based on secp256k1 algorithm
    /// - Returns: 65-byte signature of the hash data
    /// - Throws: EthereumKitError.failedToSign in case private key was invalid
    public static func sign(_ hash: Data, privateKey: Data) throws -> Data {
        return Secp256k1.sign(hash, privateKey: privateKey, isPubKeyCompressed: true)
    }
    
    public static func encryptMessage(privateKey: Data, publicKey: Data, nonce: String, message: String) -> Data {
        return Secp256k1.encryptMessage(withPrivateKey: privateKey, publicKey: publicKey, nonce: nonce, message: message)
    }
    
    public static func decryptMessage(privateKey: Data, publicKey: Data, nonce: String, message: Data) -> String {
        return Secp256k1.decryptMessage(withPrivateKey: privateKey, publicKey: publicKey, nonce: nonce, message: message)
    }
    
    public static func getPublicKeyFromAddress(_ address: String, networkPrefix: String) -> Data {
        
        var address = address
        if let range = address.range(of: networkPrefix) {
            address.removeSubrange(range)
        }
        
        var data = Base58.decode(address)
        data.removeLast(4)
        
        return data
    }
}
