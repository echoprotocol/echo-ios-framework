//
//  ContractLogEVM.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 19/11/2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Represents EVM Contract Log object from blockchain
 */
public struct ContractLogEVM: Decodable {
    
    private enum ContractLogEVMCodingKeys: String, CodingKey {
        case address
        case calledMethodsHashes = "log"
        case data
        case blockNum = "block_num"
        case trxNum = "trx_num"
        case opNum = "op_num"
    }
    
    public let address: String
    public let calledMethodsHashes: [String]
    public let data: String
    public let blockNum: IntOrString
    public let trxNum: IntOrString
    public let opNum: IntOrString
    
    public init(address: String,
                calledMethodsHashes: [String],
                data: String,
                blockNum: IntOrString,
                trxNum: IntOrString,
                opNum: IntOrString) {
        
        self.address = address
        self.calledMethodsHashes = calledMethodsHashes
        self.data = data
        self.blockNum = blockNum
        self.trxNum = trxNum
        self.opNum = opNum
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: ContractLogEVMCodingKeys.self)
        address = try values.decode(String.self, forKey: .address)
        calledMethodsHashes = try values.decode([String].self, forKey: .calledMethodsHashes)
        data = try values.decode(String.self, forKey: .data)
        blockNum = try values.decode(IntOrString.self, forKey: .blockNum)
        trxNum = try values.decode(IntOrString.self, forKey: .trxNum)
        opNum = try values.decode(IntOrString.self, forKey: .opNum)
    }
}
