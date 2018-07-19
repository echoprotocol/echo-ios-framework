//
//  ECHOKeychain.swift
//  BitcoinKit
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

import BitcoinKit

public class ECHOKeychain {
    
    let privateKey: PrivateKey
    let raw: Data
    
    public init(seed: Data) {
        privateKey = PrivateKey(data: seed)
        raw = seed
    }
    
    public convenience init?(name: String, password: String, type: KeychainType) {
        
        let seed = "\(name)" + "\(type.rawValue)" + "\(password)"

        let seedData = seed.data(using: .utf8)
            .flatMap { Crypto.sha256($0) }

        if let seedData = seedData {
            self.init(seed: seedData)
        } else {
            return nil
        }

    }
    
    func publicAddress() -> String {
        var publicKey = BitcoinKitInternal.computePublicKey(fromPrivateKey: raw, compression: true)
        let checkSum = Crypto.ripemd160(publicKey).prefix(4)
        publicKey.append(checkSum)
        return Base58.encode(publicKey)
    }
}
