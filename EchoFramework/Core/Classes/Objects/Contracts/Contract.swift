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
        case ethAccuracy = "eth_accuracy"
    }
    
    public var id: String
    public let ethAccuracy: Bool?
    public let contractCode: String?
    public let assetAmount: AssetAmount?
 
    public init(
        id: String,
        ethAccuracy: Bool? = nil,
        contractCode: String? = nil,
        assetAmount: AssetAmount? = nil
    ) {
        self.id = id
        self.contractCode = contractCode
        self.assetAmount = assetAmount
        self.ethAccuracy = ethAccuracy
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: ContractCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        ethAccuracy = try? values.decode(Bool.self, forKey: .ethAccuracy)
        contractCode = try? values.decode(String.self, forKey: .code)
        assetAmount = try? values.decode(AssetAmount.self, forKey: .amount)
    }
}
