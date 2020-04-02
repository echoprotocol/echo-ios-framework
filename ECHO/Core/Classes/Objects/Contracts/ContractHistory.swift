//
//  ContractHistory.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 18/05/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

/**
    Represents Contract History object from blockchain
 */
public struct ContractHistory: ECHOObject, Decodable {
    
    private enum ContractHistoryCodingKeys: String, CodingKey {
        case id
        case contract
        case operationId = "operation_id"
        case sequence
        case nextId
        case parentOpId = "parent_op_id"
    }
    
    public var id: String
    public let contract: Contract
    public let operationId: String
    public let sequence: Int
    public let nextId: String?
    public let parentOpId: String?
    
    public init(id: String, contract: Contract, operationId: String, sequence: Int = 0, nextId: String?, parentOpId: String? = nil) {
        
        self.id = id
        self.contract = contract
        self.operationId = operationId
        self.sequence = sequence
        self.nextId = nextId
        self.parentOpId = parentOpId
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: ContractHistoryCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        let contractId = try values.decode(String.self, forKey: .contract)
        contract = Contract(id: contractId)
        operationId = try values.decode(String.self, forKey: .operationId)
        sequence = try values.decode(Int.self, forKey: .sequence)
        nextId = try? values.decode(String.self, forKey: .nextId)
        parentOpId = try? values.decode(String.self, forKey: .parentOpId)
    }
}
