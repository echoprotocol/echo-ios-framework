//
//  HistoryItem.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    This struct encapsulates single history item
 */
public struct HistoryItem: Decodable {
    
    enum HistoryItemCodingKeys: String, CodingKey {
        case blockNum = "block_num"
        case trxInBlock = "trx_in_block"
        case operationsInTrx = "op_in_trx"
        case virtualOperation = "virtual_op"
        case operation = "op"
        case id
        case result
    }
    
    public var id: String
    public var operation: BaseOperation?
    public var timestamp: Date?
    public let blockNum: Int
    public let trxInBlock: Int
    public let opInTrx: Int
    public let virtualOp: Int
    public let result: [Any]
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: HistoryItemCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        blockNum = try values.decode(Int.self, forKey: .blockNum)
        trxInBlock = try values.decode(Int.self, forKey: .trxInBlock)
        opInTrx = try values.decode(Int.self, forKey: .operationsInTrx)
        virtualOp = try values.decode(Int.self, forKey: .virtualOperation)
        result = try values.decode([AnyDecodable].self, forKey: .result).map { $0.value }
        
        let operationContainer = try values.nestedUnkeyedContainer(forKey: .operation)
        operation = mapOperation(operationContainer)
    }
    
    func mapOperation(_ container: UnkeyedDecodingContainer) -> BaseOperation? {
        
        var container = container
        
        guard let operationId = try? container.decode(Int.self) else {
            return nil
        }
        
        let decoder = OperationDecoder()
        let operation = decoder.decode(operationId, container: container)
        return operation
    }
    
    func decode<T>(type: T.Type, data: Data) throws -> T? where T: Decodable {
        return try? JSONDecoder().decode(type, from: data)
    }
}
