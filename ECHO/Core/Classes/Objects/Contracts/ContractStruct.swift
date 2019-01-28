//
//  ContractStruct.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 10.09.2018.
//

public struct ContractStruct: Decodable {
    
    private enum ContractStructCodingKeys: String, CodingKey {
        case code
        case storage
    }
    
    public let code: String
    public let storage: [String: [String]]?
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: ContractStructCodingKeys.self)
        code = try values.decode(String.self, forKey: .code)
        storage = try? values.decode([String: [String]].self, forKey: .storage)
    }
}
