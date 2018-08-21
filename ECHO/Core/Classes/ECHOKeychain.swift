//
//  ECHOKeychain.swift
//  BitcoinKit
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

public class ECHOKeychain {
    
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
    
    func publicAddress() -> String {
        
        var publicKey = core.generatePublicKey(withPrivateKey: raw, compression: true)
        let checkSum = core.ripemd160(publicKey).prefix(4)
        publicKey.append(checkSum)
        return Base58.encode(publicKey)
    }
}
