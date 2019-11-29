//
//  RegistrationTask.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 16.10.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Task needed for calculating pow algorithm to perform registration
 */
public struct RegistrationTask: Decodable {
    
    enum RegistrationTaskKeys: String, CodingKey {
        case blockId = "block_id"
        case randNum = "rand_num"
        case difficulty
    }
    
    public let blockId: String
    public let randNum: UIntOrString
    public let difficulty: UInt8
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: RegistrationTaskKeys.self)
        blockId = try values.decode(String.self, forKey: .blockId)
        randNum = try values.decode(UIntOrString.self, forKey: .randNum)
        difficulty = try values.decode(UInt8.self, forKey: .difficulty)
    }
}


