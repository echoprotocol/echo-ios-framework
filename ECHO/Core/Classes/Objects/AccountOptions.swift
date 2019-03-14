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
        case memo = "memo_key"
        case committee = "num_committee"
        case witness = "num_witness"
        case votes
        case votingAccount = "voting_account"
        case extensions
        case delegatingAccount = "delegating_account"
    }
    
    let proxyToSelf = "1.2.5"
    
    let memo: Address?
    let votingAccount: Account
    let delegatingAaccount: Account
    var witnessCount: Int = 0
    var committeeCount: Int = 0
    var votes: [Vote] = [Vote]()
    
    private var extensions = Extensions()
    
    init(memo: Address, votingAccount: Account?, delegatingAccount: Account?) {
        self.memo = memo
        if let votingAccount = votingAccount {
            self.votingAccount = votingAccount
        } else {
            self.votingAccount = Account(proxyToSelf)
        }
        if let delegatingAccount = delegatingAccount {
            self.delegatingAaccount = delegatingAccount
        } else {
            self.delegatingAaccount = Account(proxyToSelf)
        }
    }
    
    public init(from decoder: Decoder) throws {

        let values = try decoder.container(keyedBy: AccountOptionsCodingKeys.self)
        
        let memoString = try values.decode(String.self, forKey: .memo)
        memo = Address(memoString, data: nil)
        
        let voitingAccountIdString = try values.decode(String.self, forKey: .votingAccount)
        votingAccount = Account(voitingAccountIdString)
        
        let delegatingAccountIdString = try values.decode(String.self, forKey: .delegatingAccount)
        delegatingAaccount = Account(delegatingAccountIdString)
        
        witnessCount = try values.decode(Int.self, forKey: .witness)
        committeeCount = try values.decode(Int.self, forKey: .committee)
    }
    
    // MARK: ECHOCodable
    
    public func toJSON() -> Any? {
        
        var votesArray = [Any]()
        votes.forEach {
            if let voteJSON: Any = $0.toJSON() {
                votesArray.append(voteJSON)
            }
        }
        
        let dictionary: [AnyHashable: Any?] = [AccountOptionsCodingKeys.memo.rawValue: memo?.addressString,
                                               AccountOptionsCodingKeys.committee.rawValue: committeeCount,
                                               AccountOptionsCodingKeys.witness.rawValue: witnessCount,
                                               AccountOptionsCodingKeys.votingAccount.rawValue: votingAccount.id,
                                               AccountOptionsCodingKeys.delegatingAccount.rawValue: delegatingAaccount.id,
                                               AccountOptionsCodingKeys.votes.rawValue: votesArray,
                                               AccountOptionsCodingKeys.extensions.rawValue: extensions.toJSON()]
        
        return dictionary
    }
    
    public func toData() -> Data? {
        
        guard let memo = memo else {
            return Data.init(count: 1)
        }
        
        var data = Data()
        data.append(1)
        data.append(optional: memo.toData())
        
        data.append(optional: votingAccount.toData())
        data.append(optional: delegatingAaccount.toData())
        
        data.append(Data.fromInt16(witnessCount))
        
        data.append(Data.fromInt16(committeeCount))

        let votesData = Data.fromArray(votes) {
            return $0.toData()
        }
        data.append(votesData)
        
        data.append(optional: extensions.toData())
        
        return data
    }
}
