//
//  UserAccount.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//



public class UserAccount: Decodable {
    
    enum UserAccountCodingKeys: String, CodingKey {
        case account
        case balances
    }
    
    var account: Account
    var balances: [AccountBalance]
    
    required public init(from decoder:Decoder) throws {
        
        let values = try decoder.container(keyedBy: UserAccountCodingKeys.self)
        account = try values.decode(Account.self, forKey: .account)
        balances = try values.decode([AccountBalance].self, forKey: .balances)
    }
}
