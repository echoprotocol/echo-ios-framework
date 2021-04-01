//
//  Statistics.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 23.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Represents Statistics in Graphene blockchain
 */
public struct Statistics: ECHOObject, Decodable {
    
    enum StatisticsCodingKeys: String, CodingKey {
        case id
        case mostRecentOp = "most_recent_op"
        case owner
        case removedOps = "removed_ops"
        case totalCoreInOrders = "total_core_in_orders"
        case totalOps = "total_ops"
    }
    
    public let id: String
    public let mostRecentOp: String
    public let owner: String
    public let removedOps: Int
    public let totalCoreInOrders: Int
    public let totalOps: Int
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: StatisticsCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        removedOps = try values.decode(Int.self, forKey: .removedOps)
        totalCoreInOrders = try values.decode(Int.self, forKey: .totalCoreInOrders)
        totalOps = try values.decode(Int.self, forKey: .totalOps)
        mostRecentOp = try values.decode(String.self, forKey: .mostRecentOp)
        owner = try values.decode(String.self, forKey: .owner)
    }
}
