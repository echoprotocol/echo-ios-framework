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
}

/**
    Encapsulates [ECHOKeychain](ECHOKeychain) for all types
 */
final public class AddressKeysContainer {
    
    public let ownerKeychain: ECHOKeychain
    public let activeKeychain: ECHOKeychain
    public let memoKeychain: ECHOKeychain

    public init?(login: String, password: String, core: CryptoCoreComponent) {
        
        guard let ownerKeychain = ECHOKeychain(name: login, password: password, type: .owner, core: core),
            let activeKeychain = ECHOKeychain(name: login, password: password, type: .active, core: core),
            let memoKeychain = ECHOKeychain(name: login, password: password, type: .memo, core: core) else {
                return nil
        }
        
        self.ownerKeychain = ownerKeychain
        self.activeKeychain = activeKeychain
        self.memoKeychain = memoKeychain
    }
}
