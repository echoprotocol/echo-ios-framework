//
//  Options.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Represents Options in Graphene blockchain
 */
public struct Options: Decodable {
    
    enum OptionsCodingKeys: String, CodingKey {
        case extensions
        case delegatingAccount = "delegating_account"
    }
    
    public let delegatingAccount: String
    public let extensions = [Any]()
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: OptionsCodingKeys.self)
        delegatingAccount = try values.decode(String.self, forKey: .delegatingAccount)
    }
}
