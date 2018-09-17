//
//  ContractInfo.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 10.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public struct ContractInfo: ECHOObject, Decodable {
    
    private enum ContractInfoCodingKeys: String, CodingKey {
        case id
        case statistics
        case suicided
    }
    
    var id: String
    let statistics: String
    let suicided: Bool
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: ContractInfoCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        statistics = try values.decode(String.self, forKey: .statistics)
        suicided = try values.decode(Bool.self, forKey: .suicided)
    }
}
