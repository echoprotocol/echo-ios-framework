//
//  DepositEth.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 11/06/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

public struct DepositEth: ECHOObject, Decodable {
    
    enum DepositEthKeys: String, CodingKey {
        case id
        case depositId = "deposit_id"
        case account
        case value
        case isApproved = "is_approved"
        case approves
    }
    
    public var id: String
    public let depositId: UInt
    public let account: Account
    public let value: UInt
    public let isApproved: Bool
    public let approves: [String]
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: DepositEthKeys.self)
        id = try values.decode(String.self, forKey: .id)
        depositId = try values.decode(UInt.self, forKey: .depositId)
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        value = try values.decode(UInt.self, forKey: .value)
        isApproved = try values.decode(Bool.self, forKey: .isApproved)
        approves = try values.decode([String].self, forKey: .approves)
    }
}
