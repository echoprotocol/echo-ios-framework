//
//  Options.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

/**
    Represents Options in Graphene blockchain
 */
public struct Options: Decodable {
    
    enum OptionsCodingKeys: String, CodingKey {
        case memoKey = "memo_key"
        case votingAccount = "voting_account"
        case numWitness = "num_witness"
        case numCommittee = "num_committee"
        case votes
        case extensions
    }
    
    public let memoKey: String
    public let votingAccount: String
    public let numWitness: Int
    public let numCommittee: Int
    public let votes = [Any]()
    public let extensions = [Any]()
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: OptionsCodingKeys.self)
        memoKey = try values.decode(String.self, forKey: .memoKey)
        votingAccount = try values.decode(String.self, forKey: .votingAccount)
        numWitness = try values.decode(Int.self, forKey: .numWitness)
        numCommittee = try values.decode(Int.self, forKey: .numCommittee)
    }
}
