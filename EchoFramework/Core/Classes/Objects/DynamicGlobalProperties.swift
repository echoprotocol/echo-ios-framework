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
        case headBlockNumber = "head_block_number"
        case headBlockId = "head_block_id"
        case time
        case nextMaintenanceTime = "next_maintenance_time"
        case lastMaintenanceTime = "last_maintenance_time"
        case lastIrreversibleBlockNum = "last_irreversible_block_num"
        case lastBlockOfPreviousInterval = "last_block_of_previous_interval"
        case payedBlocksInInterval = "payed_blocks_in_interval"
        case lastProcessedBTCBlock = "last_processed_btc_block"
    }
    
    public let id: String
    public let headBlockNumber: Int
    public let headBlockId: String
    public let time: String
    public let nextMaintenanceTime: String
    public let lastMaintenanceTime: String
    public let lastIrreversibleBlockNum: Int
    public let lastBlockOfPreviousInterval: Int
    public let payedBlocksInInterval: Int
    public let lastProcessedBTCBlock: Int
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: DynamicGlobalPropertiesCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        headBlockNumber = try values.decode(Int.self, forKey: .headBlockNumber)
        headBlockId = try values.decode(String.self, forKey: .headBlockId)
        time = try values.decode(String.self, forKey: .time)
        nextMaintenanceTime = try values.decode(String.self, forKey: .nextMaintenanceTime)
        lastMaintenanceTime = try values.decode(String.self, forKey: .lastMaintenanceTime)
        lastIrreversibleBlockNum = try values.decode(Int.self, forKey: .lastIrreversibleBlockNum)
        lastBlockOfPreviousInterval = try values.decode(Int.self, forKey: .lastBlockOfPreviousInterval)
        payedBlocksInInterval = try values.decode(Int.self, forKey: .payedBlocksInInterval)
        lastProcessedBTCBlock = try values.decode(Int.self, forKey: .lastProcessedBTCBlock)
    }
}
