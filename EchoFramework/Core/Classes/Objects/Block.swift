//
//  Block.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 24.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Represents block model in Graphene blockchain
 
    [Block model documentations](https://dev-doc.myecho.app/structgraphene_1_1chain_1_1signed__block.html)
 */
public struct Block: Decodable {
    
    enum BlockCodingKeys: String, CodingKey {
        case previous
        case timestamp
        case transactionMerkleRoot = "transaction_merkle_root"
        case transactions
        case round
        case account
        case vmRoot = "vm_root"
        case prevSignatures = "prev_signatures"
        case delegate = "delegate"
        case rand
    }
    
    public let previous: String
    public let timestamp: String
    public let transactionMerkleRoot: String
    public let transactions: [Transaction]
    public let round: Int
    public let account: Account
    public let vmRoot: [String]
    public let prevSignatures: [Signatures]
    public let accountDelegate: Account
    public let rand: String
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: BlockCodingKeys.self)
        previous = try values.decode(String.self, forKey: .previous)
        timestamp = try values.decode(String.self, forKey: .timestamp)
        transactionMerkleRoot = try values.decode(String.self, forKey: .transactionMerkleRoot)
        transactions = try values.decode([Transaction].self, forKey: .transactions)
        round = try values.decode(Int.self, forKey: .round)
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        vmRoot = try values.decode([String].self, forKey: .vmRoot)
        prevSignatures = try values.decode([Signatures].self, forKey: .prevSignatures)
        let delegateId = try values.decode(String.self, forKey: .delegate)
        accountDelegate = Account(delegateId)
        rand = try values.decode(String.self, forKey: .rand)
    }
}
