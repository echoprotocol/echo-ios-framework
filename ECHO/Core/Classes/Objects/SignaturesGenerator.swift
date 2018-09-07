//
//  SignaturesGenerator.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 30.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Contrains logic for sign transactions by private keys
 */
struct SignaturesGenerator {
    
    /**
     Generate array of signatures for transaction by private key
     - Parameter transaction: [Transaction](Transaction) for sign
     - Parameter privateKeys: privateKeys like [[Data](Data)]
     - Parameter cryptoCore: [CryptoCoreComponent](CryptoCoreComponent)
     
     - Return: array of signatures [[Data](Data)]
     */
    func signTransaction(_ transaction: Transaction, privateKeys: [Data], cryptoCore: CryptoCoreComponent) throws -> [Data] {
        
        var isCanonical = false
        var signatures = [Data]()
        
        while !isCanonical {
            signatures.removeAll()
            
            guard let transactionData = transaction.toData() else {
                throw ECHOError.undefined
            }
            let data = cryptoCore.sha256(transactionData)
            
            for key in privateKeys {
                let signature = try cryptoCore.sign(data, privateKey: key)
                
                // Further "canonicality" tests
                if ((signature[0] & 0x80) != 0) || (signature[0] == 0) ||
                    ((signature[1] & 0x80) != 0) || ((signature[32] & 0x80) != 0) ||
                    (signature[32] == 0) || ((signature[33] & 0x80) != 0) {
                    
                    break
                } else {
                    signatures.append(signature)
                }
            }
            
            if signatures.count == privateKeys.count {
                isCanonical = true
            } else {
                transaction.increaseExpiration()
            }
        }
        
        return signatures
    }
}
