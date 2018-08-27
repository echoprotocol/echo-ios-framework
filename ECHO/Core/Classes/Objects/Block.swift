//
//  Block.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 24.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct Block: Decodable {
    
    enum BlockCodingKeys: String, CodingKey {
        case previous
        case timestamp
        case witness
        case transactionMerkleRoot = "transaction_merkle_root"
        case witnessSignature = "witness_signature"
        case transactions
    }
    
    let previous: String
    let timestamp: String
    let witness: String
    let transactionMerkleRoot: String
    let witnessSignature: String
    let transactions: [Any]?
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: BlockCodingKeys.self)
        previous = try values.decode(String.self, forKey: .previous)
        timestamp = try values.decode(String.self, forKey: .timestamp)
        witness = try values.decode(String.self, forKey: .witness)
        transactionMerkleRoot = try values.decode(String.self, forKey: .transactionMerkleRoot)
        witnessSignature = try values.decode(String.self, forKey: .witnessSignature)
        
        //TODO: Add decode transactions array
        transactions = nil
    }
}
