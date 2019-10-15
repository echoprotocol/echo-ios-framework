//
//  AccountOptions.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 17.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Represents account options model in Graphene blockchain
 
    [AccountOptions model documentation](https://dev-doc.myecho.app/structgraphene_1_1chain_1_1account__options.html)
 */
public struct AccountOptions: ECHOCodable, Decodable {
    
    enum AccountOptionsCodingKeys: String, CodingKey {
        case committee = "num_committee"
        case votes
        case votingAccount = "voting_account"
        case extensions
        case delegatingAccount = "delegating_account"
        case delegateShare = "delegate_share"
    }
    
    let proxyToSelf = "1.2.5"
    
    let votingAccount: Account
    let delegatingAccount: Account
    var delegateShare: Int = 0
    var committeeCount: Int = 0
    var votes: [Vote] = [Vote]()
    
    private var extensions = Extensions()
    
    init(votingAccount: Account?, delegatingAccount: Account?) {
        
        if let votingAccount = votingAccount {
            self.votingAccount = votingAccount
        } else {
            self.votingAccount = Account(proxyToSelf)
        }
        if let delegatingAccount = delegatingAccount {
            self.delegatingAccount = delegatingAccount
        } else {
            self.delegatingAccount = Account(proxyToSelf)
        }
    }
    
    public init(from decoder: Decoder) throws {

        let values = try decoder.container(keyedBy: AccountOptionsCodingKeys.self)
        
        let voitingAccountIdString = try values.decode(String.self, forKey: .votingAccount)
        votingAccount = Account(voitingAccountIdString)
        
        let delegatingAccountIdString = try values.decode(String.self, forKey: .delegatingAccount)
        delegatingAccount = Account(delegatingAccountIdString)
        
        committeeCount = try values.decode(Int.self, forKey: .committee)
        delegateShare = try values.decode(Int.self, forKey: .delegateShare)
    }
    
    // MARK: ECHOCodable
    
    public func toJSON() -> Any? {
        
        var votesArray = [Any]()
        votes.forEach {
            if let voteJSON: Any = $0.toJSON() {
                votesArray.append(voteJSON)
            }
        }
        
        let dictionary: [AnyHashable: Any?] = [AccountOptionsCodingKeys.committee.rawValue: committeeCount,
                                               AccountOptionsCodingKeys.votingAccount.rawValue: votingAccount.id,
                                               AccountOptionsCodingKeys.delegatingAccount.rawValue: delegatingAccount.id,
                                               AccountOptionsCodingKeys.delegateShare.rawValue: delegateShare,
                                               AccountOptionsCodingKeys.votes.rawValue: votesArray,
                                               AccountOptionsCodingKeys.extensions.rawValue: extensions.toJSON()]
        
        return dictionary
    }
    
    public func toData() -> Data? {
        
        var data = Data()

        data.append(optional: votingAccount.toData())
        data.append(optional: delegatingAccount.toData())
        
        data.append(Data.fromInt16(delegateShare))
        data.append(Data.fromInt16(committeeCount))

        let votesData = Data.fromArray(votes) {
            return $0.toData()
        }
        data.append(votesData)
        
        data.append(optional: extensions.toData())
        
        return data
    }
}
