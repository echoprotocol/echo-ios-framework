//
//  ContractStruct.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 10.09.2018.
//

public struct ContractStruct: Decodable {
    
    private enum ContractStructCodingKeys: String, CodingKey {
        case contractInfo = "contract_info"
        case code
        case storage
    }
    
    public let contractInfo: ContractInfo
    public let code: String
    public let storage: [[String]]?
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: ContractStructCodingKeys.self)
        contractInfo = try values.decode(ContractInfo.self, forKey: .contractInfo)
        code = try values.decode(String.self, forKey: .code)
        storage = try? values.decode([[String]].self, forKey: .storage)
    }
}
