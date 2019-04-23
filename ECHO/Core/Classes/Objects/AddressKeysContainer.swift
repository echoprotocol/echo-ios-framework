//
//  AddressKeysContainer.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 19.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public enum KeychainType: String {
    case active
    case memo
    case echorand
}

/**
    Encapsulates [ECHOKeychain](ECHOKeychain) for all types
 */
final public class AddressKeysContainer {
    
    public let activeKeychain: ECHOKeychain
    public let memoKeychain: ECHOKeychain
    public let echorandKeychain: ECHOKeychain

    public init?(login: String, password: String, core: CryptoCoreComponent) {
        
        guard let activeKeychain = ECHOKeychainEd25519(name: login, password: password, type: .active, core: core),
            let memoKeychain = ECHOKeychainSecp256k1(name: login, password: password, type: .active, core: core),
            let echorandKeychain = ECHOKeychainEd25519(name: login, password: password, type: .active, core: core) else {
                return nil
        }
        
        self.activeKeychain = activeKeychain
        self.memoKeychain = memoKeychain
        self.echorandKeychain = echorandKeychain
    }
    
    public init?(wif: String, core: CryptoCoreComponent) {
        
        guard let activeKeychain = ECHOKeychainEd25519(wif: wif, core: core),
            let memoKeychain = ECHOKeychainEd25519(wif: wif, core: core),
            let echorandKeychain = ECHOKeychainEd25519(wif: wif, core: core) else {
                return nil
        }
        
        self.activeKeychain = activeKeychain
        self.memoKeychain = memoKeychain
        self.echorandKeychain = echorandKeychain
    }
}
