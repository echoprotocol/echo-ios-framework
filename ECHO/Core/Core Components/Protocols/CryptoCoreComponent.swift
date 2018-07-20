//
//  CryptoCoreComponent.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 12.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public protocol CryptoCoreComponent {
    func generatePublicKey(withPrivateKey privateKeyData: Data?, compression isCompression: Bool) -> Data
    func sha256(_ data: Data) -> Data
    func ripemd160(_ data: Data) -> Data
    func sign(_ hash: Data, privateKey: Data) throws -> Data
}

class CryptoCoreComponentImp: CryptoCoreComponent {
    
    public func generatePublicKey(withPrivateKey privateKeyData: Data?, compression isCompression: Bool) -> Data {
        return Data()
    }
    
    public func sha256(_ data: Data) -> Data {
        return Data()
    }
    
    public func ripemd160(_ data: Data) -> Data {
        return Data()
    }
    
    func sign(_ hash: Data, privateKey: Data) throws -> Data {
        return Data()
    }
}
