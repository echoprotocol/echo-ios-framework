//
//  Options.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

class Options: Decodable {
    
    enum OptionsCodingKeys: String, CodingKey {
        case memoKey = "memo_key"
        case votingAccount = "voting_account"
        case numWitness = "num_witness"
        case numCommittee = "num_committee"
        case votes
        case extensions
    }
    
    var memoKey: String
    var votingAccount: String
    var numWitness: Int
    var numCommittee: Int
    var votes = [Any]()
    var extensions = [Any]()
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: OptionsCodingKeys.self)
        memoKey = try values.decode(String.self, forKey: .memoKey)
        votingAccount = try values.decode(String.self, forKey: .votingAccount)
        numWitness = try values.decode(Int.self, forKey: .numWitness)
        numCommittee = try values.decode(Int.self, forKey: .numCommittee)
    }
}
