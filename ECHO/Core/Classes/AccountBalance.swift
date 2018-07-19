//
//  AccountBalance.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//


public class AccountBalance: GrapheneObject, Decodable {
    
    enum AccountBalanceCodingKeys: String, CodingKey {
        case assetType = "asset_type"
        case owner
        case id
        case balance
    }
    
    var assetType: String
    var owner: String
    var balance: String

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: AccountBalanceCodingKeys.self)
        let id = try values.decode(String.self, forKey: .id)
        assetType = try values.decode(String.self, forKey: .assetType)
        owner = try values.decode(String.self, forKey: .owner)
        balance = try values.decode(String.self, forKey: .balance)
        super.init(string: id)
    }
}
