//
//  ContractResultx86.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 19/02/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Model of contract operation result for VM type x86
 */
public struct ContractResultx86: Decodable {

    private enum ContractResultx86CodingKeys: String, CodingKey {
        case output
    }
    
    public let output: String
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: ContractResultx86CodingKeys.self)
        output = try values.decode(String.self, forKey: .output)
    }
}
