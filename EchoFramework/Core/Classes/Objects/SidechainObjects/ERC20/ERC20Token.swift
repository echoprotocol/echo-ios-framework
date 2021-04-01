//
//  ERC20Token.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 31.10.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Information about erc20 token
 */
public struct ERC20Token: ECHOObject, Decodable {

    enum ERC20TokenCodingKeys: String, CodingKey {
        case id
        case owner
        case ethAddress = "eth_addr"
        case contract
        case name
        case symbol
        case decimals
    }
    
    public var id: String
    public var owner: String?
    public var ethAddress: String?
    public var contract: String?
    public var name: String?
    public var symbol: String?
    public var decimals: UInt8?
    
    public init(id: String) {
        self.id = id
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: ERC20TokenCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        owner = try values.decode(String.self, forKey: .owner)
        ethAddress = try values.decode(String.self, forKey: .ethAddress)
        contract = try values.decode(String.self, forKey: .contract)
        name = try values.decode(String.self, forKey: .name)
        symbol = try values.decode(String.self, forKey: .symbol)
        decimals = try values.decode(UInt8.self, forKey: .decimals)
    }
}
