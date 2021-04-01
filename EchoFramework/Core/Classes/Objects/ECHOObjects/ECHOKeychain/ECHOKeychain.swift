//
//  ECHOKeychain.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Container which create private key from wif, seed, random
 */
public protocol ECHOKeychain: class {
    
    var raw: Data { get }
    var core: CryptoCoreComponent { get }
    
    init(core: CryptoCoreComponent)
    init(seed: Data, core: CryptoCoreComponent)
    init?(wif: String, core: CryptoCoreComponent)
    
    func publicKey() -> Data
    func publicAddress() -> String
    func wif() -> String
}
