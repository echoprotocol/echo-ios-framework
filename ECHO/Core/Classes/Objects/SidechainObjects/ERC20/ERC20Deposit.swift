//
//  ERC20Deposit.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 29.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
   Represents erc20_deposit_object from blockchain
*/
public struct ERC20Deposit: ECHOObject, Decodable {
    
    enum ERC20DepositCodingKeys: String, CodingKey {
        case id
        case account
        case erc20Address = "erc20_addr"
        case value
        case transactionHash = "transaction_hash"
        case isApproved = "is_approved"
        case approves
    }
    
    public var id: String
    public let account: Account
    public let erc20Address: String
    public let value: String
    public let transactionHash: String
    public let isApproved: Bool
    public let approves: [String]
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: ERC20DepositCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        erc20Address = try values.decode(String.self, forKey: .erc20Address)
        value = try values.decode(String.self, forKey: .value)
        transactionHash = try values.decode(String.self, forKey: .transactionHash)
        isApproved = try values.decode(Bool.self, forKey: .isApproved)
        approves = try values.decode([String].self, forKey: .approves)
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
    }
}

