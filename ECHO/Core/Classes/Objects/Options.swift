//
//  Options.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

public struct Options: Decodable {
    
    enum OptionsCodingKeys: String, CodingKey {
        case memoKey = "memo_key"
        case votingAccount = "voting_account"
        case numWitness = "num_witness"
        case numCommittee = "num_committee"
        case votes
        case extensions
    }
    
    public var memoKey: String
    public var votingAccount: String
    public var numWitness: Int
    public var numCommittee: Int
    public var votes = [Any]()
    public var extensions = [Any]()
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: OptionsCodingKeys.self)
        memoKey = try values.decode(String.self, forKey: .memoKey)
        votingAccount = try values.decode(String.self, forKey: .votingAccount)
        numWitness = try values.decode(Int.self, forKey: .numWitness)
        numCommittee = try values.decode(Int.self, forKey: .numCommittee)
    }
}
