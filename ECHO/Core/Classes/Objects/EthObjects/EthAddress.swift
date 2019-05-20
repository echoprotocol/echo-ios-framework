//
//  EthAddress.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 20/05/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

public struct EthAddress: ECHOObject, Decodable {
    
    enum EthAddressgKeys: String, CodingKey {
        case accountId = "acc_id"
        case address = "eth_addr"
        case isApproved = "is_approved"
        case approves
        case id
    }
    
    public var id: String
    public let accountId: String
    public let address: String
    public let isApproved: Bool
    public let approves: [String]
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: EthAddressgKeys.self)
        id = try values.decode(String.self, forKey: .id)
        accountId = try values.decode(String.self, forKey: .accountId)
        address = try values.decode(String.self, forKey: .address)
        isApproved = try values.decode(Bool.self, forKey: .isApproved)
        approves = try values.decode([String].self, forKey: .approves)
    }
}
