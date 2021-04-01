//
//  ContractLogx86.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 14.10.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Represents x86 Contract Log object from blockchain
 */
public struct ContractLogx86: Decodable {
    
    private enum ContractLogx86CodingKeys: String, CodingKey {
        case logs
    }
    
    public let logs: [ContractLogx86Entry]
    
    public init(logs: [ContractLogx86Entry]) {
        
        self.logs = logs
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: ContractLogx86CodingKeys.self)
        logs = try values.decode([ContractLogx86Entry].self, forKey: .logs)
    }
}

public struct ContractLogx86Entry: Decodable {
    
    private enum ContractLogx86EntryCodingKeys: String, CodingKey {
        case hash
        case log
        case id
        case blockNum = "block_num"
        case trxNum = "trx_num"
        case opNum = "op_num"
    }
    
    public let hash: String
    public let log: String
    public let id: IntOrString
    public let blockNum: IntOrString
    public let trxNum: IntOrString
    public let opNum: IntOrString
    
    public init(hash: String,
                log: String,
                id: IntOrString,
                blockNum: IntOrString,
                trxNum: IntOrString,
                opNum: IntOrString) {
        self.hash = hash
        self.log = log
        self.id = id
        self.blockNum = blockNum
        self.trxNum = trxNum
        self.opNum = opNum
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: ContractLogx86EntryCodingKeys.self)
        
        hash = try values.decode(String.self, forKey: .hash)
        log = try values.decode(String.self, forKey: .log)
        id = try values.decode(IntOrString.self, forKey: .id)
        blockNum = try values.decode(IntOrString.self, forKey: .blockNum)
        trxNum = try values.decode(IntOrString.self, forKey: .trxNum)
        opNum = try values.decode(IntOrString.self, forKey: .opNum)
        
    }
}
