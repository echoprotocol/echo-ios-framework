//
//  WIFValidator.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 11/07/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

public struct WIFValidator {

    private let cryptoCore: CryptoCoreComponent

    public init(cryptoCore: CryptoCoreComponent) {
        
        self.cryptoCore = cryptoCore
    }
    
    public func isValidWIF(_ wif: String) -> Bool {
        
        return cryptoCore.getPrivateKeyFromWIF(wif) != nil
    }
}
