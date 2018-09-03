//
//  UserAccount.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Represents full information about user account
 */
public struct UserAccount: Decodable {
    
    private enum UserAccountCodingKeys: String, CodingKey {
        case account
        case balances
    }
    
    public let account: Account
    public let balances: [AccountBalance]
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: UserAccountCodingKeys.self)
        account = try values.decode(Account.self, forKey: .account)
        balances = try values.decode([AccountBalance].self, forKey: .balances)
    }
}
