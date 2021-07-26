//
//  BtcAddress.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 28.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
   Represents btc address object from blockchain
*/
public struct BtcAddress: ECHOObject, Decodable {
    
    enum EthAddressKeys: String, CodingKey {
        case id
        case accountId = "account"
        case depositAddress = "deposit_address"
        case committeeMemberIdsInScript = "committee_member_ids_in_script"
        case isRelevant = "is_relevant"
        case extensions
    }
    
    public var id: String
    public let accountId: String
    public let depositAddress: BtcDepositAddress
    public let committeeMemberIdsInScript: [BtcCommitteeMemberIdInScript]
    public let isRelevant: Bool
    public let extensions: Extensions
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: EthAddressKeys.self)
        id = try values.decode(String.self, forKey: .id)
        accountId = try values.decode(String.self, forKey: .accountId)
        depositAddress = try values.decode(BtcDepositAddress.self, forKey: .depositAddress)
        let members = try values.decode([[String]].self, forKey: .committeeMemberIdsInScript)
        isRelevant = try values.decode(Bool.self, forKey: .isRelevant)
        extensions = Extensions()
        
        var committeeMemberIdsInScript = [BtcCommitteeMemberIdInScript]()
        members.forEach {
            guard let accountId = $0.first,
                let script = $0.last else {
                return
            }
            
            let member = BtcCommitteeMemberIdInScript(accountId: accountId, script: script)
            committeeMemberIdsInScript.append(member)
        }
        self.committeeMemberIdsInScript = committeeMemberIdsInScript
    }
}

public struct BtcDepositAddress: Decodable {
    public let address: String
}

public struct BtcCommitteeMemberIdInScript {
    public let accountId: String
    public let script: String
}
