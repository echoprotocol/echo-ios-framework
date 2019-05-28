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
        case memoKey = "memo_key"
        case votingAccount = "voting_account"
        case numCommittee = "num_committee"
        case votes
        case extensions
        case delegatingAccount = "delegating_account"
    }
    
    public let memoKey: String
    public let votingAccount: String
    public let delegatingAccount: String
    public let numCommittee: Int
    public let votes = [Any]()
    public let extensions = [Any]()
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: OptionsCodingKeys.self)
        memoKey = try values.decode(String.self, forKey: .memoKey)
        votingAccount = try values.decode(String.self, forKey: .votingAccount)
        numCommittee = try values.decode(Int.self, forKey: .numCommittee)
        delegatingAccount = try values.decode(String.self, forKey: .delegatingAccount)
    }
}
