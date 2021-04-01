//
//  ECHOKeychainEd25519.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 15/01/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
 Container which create private key by Ed25519 curve from wif, seed, random
 */
final public class ECHOKeychainEd25519: ECHOKeychain {
    
    public let raw: Data
    public let core: CryptoCoreComponent
    
    public init(core: CryptoCoreComponent) {
        raw = core.generateRandomEd25519PrivateKey()
        self.core = core
    }
    
    public init(seed: Data, core: CryptoCoreComponent) {
        raw = seed
        self.core = core
    }
    
    public convenience init?(wif: String, core: CryptoCoreComponent) {
        
        let privateKey = core.getPrivateKeyFromWIF(wif)
        if let privateKey = privateKey {
            self.init(seed: privateKey, core: core)
        } else {
            return nil
        }
    }
    
    public func publicKey() -> Data {
        
        return core.generatePublicEd25519Key(withPrivateKey: raw)
    }
    
    public func publicAddress() -> String {
        
        let publicKey = self.publicKey()
        return Base58.encode(publicKey)
    }
    
    public func wif() -> String {
        
        return core.getWIFFromPrivateKey(raw)
    }
}
