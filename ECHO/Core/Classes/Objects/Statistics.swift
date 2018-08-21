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
    
    public let id: String
    public let lifetimeFeesPaid: Int
    public let mostRecentOp: String
    public let owner: String
    public let pendingFees: Int
    public let pendingVestedFees: Int
    public let removedOps: Int
    public let totalCoreInOrders: Int
    public let totalOps: Int
    
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
