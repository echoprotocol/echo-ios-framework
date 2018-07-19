//
//  BlockData.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 19.07.2018.
//

public struct BlockData: ECHOObject, Decodable {
    
    enum BlockDataCodingKeys: String, CodingKey {
        case id
        case accountsRegisteredThisInterval = "accounts_registered_this_interval"
        case currentAslot = "current_aslot"
        case currentWitness = "current_witness"
        case dynamicFlags = "dynamic_flags"
        case headBlockId = "head_block_id"
        case headBlockNumber = "head_block_number"
        case lastBudgetTime = "last_budget_time"
        case lastIrreversibleBlockNum = "last_irreversible_block_num"
        case nextMaintenanceTime = "next_maintenance_time"
        case recentSlotsFilled = "recent_slots_filled"
        case recentlyMissedCount = "recently_missed_count"
        case time
        case witnessBudget = "witness_budget"
    }
    
    public var id: String
    public var accountsRegisteredThisInterval: Int
    public var currentAslot: Int
    public var currentWitness: String
    public var dynamicFlags: Int
    public var headBlockId: String
    public var headBlockNumber: Int
    public var lastBudgetTime: String
    public var lastIrreversibleBlockNum: Int
    public var nextMaintenanceTime: String
    public var recentSlotsFilled: String
    public var recentlyMissedCount: Int
    public var time: String
    public var witnessBudget: Int
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: BlockDataCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        accountsRegisteredThisInterval = try values.decode(Int.self, forKey: .accountsRegisteredThisInterval)
        currentAslot = try values.decode(Int.self, forKey: .currentAslot)
        dynamicFlags = try values.decode(Int.self, forKey: .dynamicFlags)
        headBlockNumber = try values.decode(Int.self, forKey: .headBlockNumber)
        lastIrreversibleBlockNum = try values.decode(Int.self, forKey: .lastIrreversibleBlockNum)
        recentSlotsFilled = try values.decode(String.self, forKey: .recentSlotsFilled)
        recentlyMissedCount = try values.decode(Int.self, forKey: .recentlyMissedCount)
        witnessBudget = try values.decode(Int.self, forKey: .witnessBudget)
        currentWitness = try values.decode(String.self, forKey: .currentWitness)
        headBlockId = try values.decode(String.self, forKey: .headBlockId)
        lastBudgetTime = try values.decode(String.self, forKey: .lastBudgetTime)
        nextMaintenanceTime = try values.decode(String.self, forKey: .nextMaintenanceTime)
        time = try values.decode(String.self, forKey: .time)
    }
}
