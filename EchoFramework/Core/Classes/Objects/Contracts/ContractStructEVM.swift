//
//  ContractStructEVM.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 10.09.2018.
//

public struct ContractStructEVM: Decodable {
    
    private enum ContractStructEVMCodingKeys: String, CodingKey {
        case code
        case storage
    }
    
    public let code: String
    public let storage: [String: [String]]?
    
    public init(code: String, storage: [String: [String]]?) {
        
        self.code = code
        self.storage = storage
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: ContractStructEVMCodingKeys.self)
        code = try values.decode(String.self, forKey: .code)
        storage = try? values.decode([String: [String]].self, forKey: .storage)
    }
}
