//
//  AddressKeysContainer.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 19.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public enum KeychainType: String {
    case owner
    case active
    case memo
    case echorand
}

/**
    Encapsulates [ECHOKeychain](ECHOKeychain) for all types
 */
final public class AddressKeysContainer {
    
    public let ownerKeychain: ECHOKeychain
    public let activeKeychain: ECHOKeychain
    public let memoKeychain: ECHOKeychain
    public let echorandKeychain: ECHOKeychain

    public init?(login: String, password: String, core: CryptoCoreComponent) {
        
        guard let ownerKeychain = ECHOKeychainSecp256k1(name: login, password: password, type: .owner, core: core),
            let activeKeychain = ECHOKeychainSecp256k1(name: login, password: password, type: .active, core: core),
            let memoKeychain = ECHOKeychainSecp256k1(name: login, password: password, type: .memo, core: core),
            let echorandKeychain = ECHOKeychainEd25519(name: login, password: password, type: .echorand, core: core) else {
                return nil
        }
        
        self.ownerKeychain = ownerKeychain
        self.activeKeychain = activeKeychain
        self.memoKeychain = memoKeychain
        self.echorandKeychain = echorandKeychain
    }
}
