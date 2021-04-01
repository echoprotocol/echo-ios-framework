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
        
        var signatures = [Data]()
        
        guard let transactionData = transaction.toData() else {
            throw ECHOError.undefined
        }
        
        let data = cryptoCore.sha256(transactionData)
        
        for key in privateKeys {
            let signature = cryptoCore.signByEd25519(data, privateKey: key)
            signatures.append(signature)
        }
        
        return signatures
    }
}
