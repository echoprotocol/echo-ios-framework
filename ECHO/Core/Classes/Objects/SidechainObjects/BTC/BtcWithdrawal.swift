//
//  BtcWithdrawal.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 12.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
   Represents btc_withdrawal_object from blockchain
*/
public struct BtcWithdrawal: ECHOObject, Decodable {
    
    enum BtcWithdrawalCodingKeys: String, CodingKey {
        case id
        case account
        case btcAddress = "btc_addr"
        case value
        case isSent = "is_sent"
        case echoBlockNumber = "echo_block_number"
        case isApproved = "is_approved"
    }
    
    public var id: String
    public let account: Account
    public let btcAddress: String
    public let value: UInt
    public let isSent: Bool
    public let echoBlockNumber: UInt
    public let isApproved: Bool
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: BtcWithdrawalCodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        btcAddress = try values.decode(String.self, forKey: .btcAddress)
        value = try values.decode(UInt.self, forKey: .value)
        isSent = try values.decode(Bool.self, forKey: .isSent)
        echoBlockNumber = try values.decode(UInt.self, forKey: .echoBlockNumber)
        isApproved = try values.decode(Bool.self, forKey: .isApproved)
    }
}
