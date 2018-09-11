//
//  Contract.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 11.09.2018.
//

/**
    Represents contract_object from blockchain
 */
public struct Contract: ECHOObject, Decodable {
    
    private enum ContractCodingKeys: String, CodingKey {
        case id
        case code
        case amount
    }
    
    var id: String
    let contractCode: String?
    let assetAmount: AssetAmount?
 
    public init(id: String, contractCode: String? = nil, assetAmount: AssetAmount? = nil) {
        
        self.id = id
        self.contractCode = contractCode
        self.assetAmount = assetAmount
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: ContractCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        contractCode = try? values.decode(String.self, forKey: .code)
        assetAmount = try? values.decode(AssetAmount.self, forKey: .amount)
    }
}
