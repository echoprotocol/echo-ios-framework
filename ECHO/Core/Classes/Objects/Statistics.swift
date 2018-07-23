//
//  Statistics.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 23.07.2018.
//

public struct Statistics: ECHOObject, Decodable {
    
    enum StatisticsCodingKeys: String, CodingKey {
        case id
        case lifetimeFeesPaid = "lifetime_fees_paid"
        case mostRecentOp = "most_recent_op"
        case owner
        case pendingFees = "pending_fees"
        case pendingVestedFees = "pending_vested_fees"
        case removedOps = "removed_ops"
        case totalCoreInOrders = "total_core_in_orders"
        case totalOps = "total_ops"
    }
    
    public var id: String
    public var lifetimeFeesPaid: Int
    public var mostRecentOp: String
    public var owner: String
    public var pendingFees: Int
    public var pendingVestedFees: Int
    public var removedOps: Int
    public var totalCoreInOrders: Int
    public var totalOps: Int
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: StatisticsCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        lifetimeFeesPaid = try values.decode(Int.self, forKey: .lifetimeFeesPaid)
        pendingFees = try values.decode(Int.self, forKey: .pendingFees)
        pendingVestedFees = try values.decode(Int.self, forKey: .pendingVestedFees)
        removedOps = try values.decode(Int.self, forKey: .removedOps)
        totalCoreInOrders = try values.decode(Int.self, forKey: .totalCoreInOrders)
        totalOps = try values.decode(Int.self, forKey: .totalOps)
        mostRecentOp = try values.decode(String.self, forKey: .mostRecentOp)
        owner = try values.decode(String.self, forKey: .owner)
    }
}
