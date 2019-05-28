//
//  ContractStructx86.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 19/02/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

public struct ContractStructx86: Decodable {
    
    private enum ContractStructx86CodingKeys: String, CodingKey {
        case code
    }
    
    public let code: String
    
    public init(code: String) {
        
        self.code = code
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: ContractStructx86CodingKeys.self)
        code = try values.decode(String.self, forKey: .code)
    }
}
