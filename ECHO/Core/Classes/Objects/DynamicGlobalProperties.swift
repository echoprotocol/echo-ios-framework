//
//  DynamicGlobalProperties.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 19.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Represents account model in Graphene blockchain
 
    [Dynamic global model documentations] (https://dev-doc.myecho.app/classgraphene_1_1chain_1_1dynamic__global__property__object.html)
 */
public struct DynamicGlobalProperties: ECHOObject, Decodable {
    
    public static let  defaultIdentifier: String  = "2.1.0"
    
    enum DynamicGlobalPropertiesCodingKeys: String, CodingKey {
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
    
    public let id: String
    public let accountsRegisteredThisInterval: Int
    public let currentAslot: Int
    public let currentWitness: String
    public let dynamicFlags: Int
    public let headBlockId: String
    public let headBlockNumber: Int
    public let lastBudgetTime: String
    public let lastIrreversibleBlockNum: Int
    public let nextMaintenanceTime: String
    public let recentSlotsFilled: String
    public let recentlyMissedCount: Int
    public let time: String
    public let witnessBudget: Int
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: DynamicGlobalPropertiesCodingKeys.self)
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
