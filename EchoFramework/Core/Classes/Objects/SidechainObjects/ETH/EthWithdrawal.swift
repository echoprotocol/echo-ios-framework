//
//  EthWithdrawal.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 11/06/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
   Represents eth_withdrawal_object from blockchain
*/
public struct EthWithdrawal: ECHOObject, Decodable {
    
    enum EthWithdrawalCodingKeys: String, CodingKey {
        case id
        case withdrawId = "withdraw_id"
        case account
        case ethAddress = "eth_addr"
        case value
        case fee
        case isApproved = "is_approved"
        case isSent = "is_sent"
        case approves
        case echoBlockNumber = "echo_block_number"
        case transactionHash = "transaction_hash"
    }
    
    public var id: String
    public let withdrawId: UInt
    public let account: Account
    public let ethAddress: String
    public let value: UInt
    public let fee: UInt
    public let isApproved: Bool
    public let isSent: Bool
    public let approves: [String]
    public let echoBlockNumber: UInt
    public let transactionHash: String?
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: EthWithdrawalCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        withdrawId = try values.decode(UInt.self, forKey: .withdrawId)
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        ethAddress = try values.decode(String.self, forKey: .ethAddress)
        value = try values.decode(UInt.self, forKey: .value)
        fee = try values.decode(UInt.self, forKey: .fee)
        isApproved = try values.decode(Bool.self, forKey: .isApproved)
        isSent = try values.decode(Bool.self, forKey: .isSent)
        approves = try values.decode([String].self, forKey: .approves)
        echoBlockNumber = try values.decode(UInt.self, forKey: .echoBlockNumber)
        transactionHash = try? values.decode(String.self, forKey: .transactionHash)
    }
}
