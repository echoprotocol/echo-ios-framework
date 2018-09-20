//
//  ECHOKeychain.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Container which create private key from name, password, type
 */
final public class ECHOKeychain {
    
    public let raw: Data
    public let core: CryptoCoreComponent
    
    public init(seed: Data, core: CryptoCoreComponent) {
        raw = seed
        self.core = core
    }
    
    public convenience init?(name: String, password: String, type: KeychainType, core: CryptoCoreComponent) {
        
        let seed = "\(name)" + "\(type.rawValue)" + "\(password)"

        let seedData = seed.data(using: .utf8)
            .flatMap { core.sha256($0) }

        if let seedData = seedData {
            self.init(seed: seedData, core: core)
        } else {
            return nil
        }
    }
    
    public func publicKey() -> Data {
        
        return core.generatePublicKey(withPrivateKey: raw, compression: true)
    }
    
    public func publicAddress() -> String {
        
        var publicKey = self.publicKey()
        
        let checkSum = core.ripemd160(publicKey).prefix(4)
        publicKey.append(checkSum)
        
        return Base58.encode(publicKey)
    }
}
