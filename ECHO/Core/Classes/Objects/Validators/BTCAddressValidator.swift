//
//  BTCAddressValidator.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 28.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

public struct BTCAddressValidator {
    
    private let cryptoCore: CryptoCoreComponent
    
    private let minLenght = 26
    private let maxLenght = 35
    private let checksumLenght = 4
    private let base58Lenght = 25
    
    public init(cryptoCore: CryptoCoreComponent) {
        
        self.cryptoCore = cryptoCore
    }
    
    public func isValidBTCAddress(_ btcAddress: String) -> Bool {
        
        guard btcAddress.count >= minLenght && btcAddress.count <= maxLenght else {
            return false
        }
        
        let decoded = Base58.decode(btcAddress)
        let nonChecksum = decoded.subdata(in: 0..<(base58Lenght - checksumLenght))
        let checksum = decoded.subdata(in: (base58Lenght - checksumLenght)..<base58Lenght)
        
        let hash1 = cryptoCore.sha256(nonChecksum)
        let hash2 = cryptoCore.sha256(hash1)
        let calculatedChecksum = hash2.subdata(in: 0..<checksumLenght)
        
        return checksum.elementsEqual(calculatedChecksum)
    }
}
