//
//  AddressKeysContainer.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 19.07.2018.
//

public enum KeychainType: String {
    case owner
    case active
    case memo
}

class AddressKeysContainer {
    
    var ownerKeychain: ECHOKeychain
    var activeKeychain: ECHOKeychain
    var memoKeychain: ECHOKeychain

    init?(login: String, password: String) {
        
        guard let ownerKeychain = ECHOKeychain(name: login, password: password, type: .owner),
            let activeKeychain = ECHOKeychain(name: login, password: password, type: .active),
            let memoKeychain = ECHOKeychain(name: login, password: password, type: .memo) else {
                return nil
        }
        
        self.ownerKeychain = ownerKeychain
        self.activeKeychain = activeKeychain
        self.memoKeychain = memoKeychain
    }
}
