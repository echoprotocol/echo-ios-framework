//
//  BtcDeposit.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 12.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
   Represents btc_deposit_object from blockchain
*/
public struct BtcDeposit: ECHOObject, Decodable {
    enum BtcDepositCodingKeys: String, CodingKey {
        case id
        case account
        case intermediateDepositId = "intermediate_deposit_id"
        case txInfo = "tx_info"
        case isApproved = "is_approved"
        case isSent = "is_sent"
        case approves
    }
    
    public var id: String
    public let account: Account
    public let intermediateDepositId: String
    public let txInfo: BtcDepositTransactionInfo
    public let isSent: Bool
    public let isApproved: Bool
    public let approves: [String]
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: BtcDepositCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        intermediateDepositId = try values.decode(String.self, forKey: .intermediateDepositId)
        txInfo = try values.decode(BtcDepositTransactionInfo.self, forKey: .txInfo)
        isSent = try values.decode(Bool.self, forKey: .isSent)
        isApproved = try values.decode(Bool.self, forKey: .isApproved)
        approves = try values.decode([String].self, forKey: .approves)
    }
}

public struct BtcDepositTransactionInfo: Decodable {
    enum BtcDepositTransactionInfoCodingKeys: String, CodingKey {
        case blockNumber = "block_number"
        case output = "out"
    }
    
    public let blockNumber: UInt
    public let output: BtcDepositTransactionOutput
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: BtcDepositTransactionInfoCodingKeys.self)
        blockNumber = try values.decode(UInt.self, forKey: .blockNumber)
        output = try values.decode(BtcDepositTransactionOutput.self, forKey: .output)
    }
}

public struct BtcDepositTransactionOutput: Decodable {
    enum BtcDepositTransactionOutputCodingKeys: String, CodingKey {
        case txId = "tx_id"
        case index
        case amount
    }
    
    public let txId: String
    public let index: UInt
    public let amount: UInt
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: BtcDepositTransactionOutputCodingKeys.self)
        
        txId = try values.decode(String.self, forKey: .txId)
        index = try values.decode(UInt.self, forKey: .index)
        amount = try values.decode(UInt.self, forKey: .amount)
    }
}
