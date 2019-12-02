//
//  ERC20Withdrawal.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 29.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
   Represents erc20_withdrawal_object from blockchain
*/
public struct ERC20Withdrawal: ECHOObject, Decodable {
    
    enum ERC20WithdrawalCodingKeys: String, CodingKey {
        case id
        case withdrawId = "withdraw_id"
        case account
        case toAddress = "to"
        case erc20Token = "erc20_token"
        case value
        case isApproved = "is_approved"
        case approves
    }
    
    public var id: String
    public let withdrawId: UInt
    public let account: Account
    public let toAddress: String
    public let erc20Token: Contract
    public let value: String
    public let isApproved: Bool
    public let approves: [String]
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: ERC20WithdrawalCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        withdrawId = try values.decode(UInt.self, forKey: .withdrawId)
        toAddress = try values.decode(String.self, forKey: .toAddress)
        value = try values.decode(String.self, forKey: .value)
        isApproved = try values.decode(Bool.self, forKey: .isApproved)
        approves = try values.decode([String].self, forKey: .approves)
        
        let contractId = try values.decode(String.self, forKey: .erc20Token)
        erc20Token = Contract(id: contractId)
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
    }
}
