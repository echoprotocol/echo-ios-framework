
//
//  ETHAddressValidator.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 11/03/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

struct ETHAddressValidator {
    
    let cryptoCore: CryptoCoreComponent
    
    fileprivate let addressPattern = "^(0x)?[0-9a-f]{40}$"
    fileprivate let lowerCaseAddressPattern = "^(0x)?[0-9a-f]{40}$"
    fileprivate let upperCaseAddressPattern = "^(0x)?[0-9A-F]{40}$"
    
    init(cryptoCore: CryptoCoreComponent) {
        
        self.cryptoCore = cryptoCore
    }
    
    func isValidETHAddress(_ ethAddress: String) -> Bool {
        
        if !matchesPattern(ethAddress) {
            return false
        }
        
        let sameCaps = isAllSameCaps(ethAddress)
        if !sameCaps {
            return isValidChecksum(ethAddress)
        }
        
        return sameCaps
    }
    
    fileprivate func matchesPattern(_ ethAddress: String) -> Bool {
        
        if let regex = try? NSRegularExpression(pattern: addressPattern, options: .caseInsensitive) {
            let muchNumber = regex.numberOfMatches(in: ethAddress,
                                                   options: [],
                                                   range: NSMakeRange(0, ethAddress.count))
            return muchNumber > 0
        } else {
            return false
        }
    }
    
    fileprivate func isAllSameCaps(_ ethAddress: String) -> Bool {
        
        if let lowerCaseRegex = try? NSRegularExpression(pattern: lowerCaseAddressPattern, options: []),
            let upperCaseRegex = try? NSRegularExpression(pattern: upperCaseAddressPattern, options: []) {
            
            let lowerCaseMuchNumber = lowerCaseRegex.numberOfMatches(in: ethAddress,
                                                                     options: [],
                                                                     range: NSMakeRange(0, ethAddress.count))
            let upperCaseMuchNumber = upperCaseRegex.numberOfMatches(in: ethAddress,
                                                                     options: [],
                                                                     range: NSMakeRange(0, ethAddress.count))
            
            return lowerCaseMuchNumber > 0 || upperCaseMuchNumber > 0
        } else {
            return false
        }
    }
    
    fileprivate func isValidChecksum(_ ethAddress: String) -> Bool {
        
        let address = ethAddress.replacingOccurrences(of: "0x", with: "")
        
        guard let data = address.lowercased().data(using: .utf8) else {
            return false
        }
        
        let hash = cryptoCore.keccak256(data).hex
        
        let letters = NSCharacterSet.letters
        let upperLetters = NSCharacterSet.uppercaseLetters
        let lowerLetters = NSCharacterSet.lowercaseLetters
        
        // See: https://github.com/web3j/web3j/pull/134/files#diff-db8702981afff54d3de6a913f13b7be4R42
        for index in 0..<40 {
            let characterString = address[index..<index + 1]
            if characterString.rangeOfCharacter(from: letters) != nil {
             
                // Each uppercase letter should correlate with a first bit of 1 in the hash char with the same index,
                // and each lowercase letter with a 0 bit.
                guard let charInt = Int(hash[index..<index + 1], radix: 16) else {
                    return false
                }
                
                let hasLowerRange = characterString.rangeOfCharacter(from: lowerLetters) != nil
                let hasUpperRange = characterString.rangeOfCharacter(from: upperLetters) != nil

                if (hasUpperRange && charInt <= 7) || (hasLowerRange && charInt > 7) {
                    return false
                }
            }
        }
        
        return true
    }
}
