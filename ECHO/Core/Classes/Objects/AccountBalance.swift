//
//  AccountBalance.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Represents balance model in Graphene blockchain
 
    [AccountBalance model documentation](https://dev-doc.myecho.app/classgraphene_1_1chain_1_1account__balance__object.html)
 */
public struct AccountBalance: ECHOObject, Decodable {
    
    enum AccountBalanceCodingKeys: String, CodingKey {
        case assetType = "asset_type"
        case owner
        case id
        case balance
    }
    
    let assetType: String
    let owner: String
    let balance: Int
    let id: String

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: AccountBalanceCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        assetType = try values.decode(String.self, forKey: .assetType)
        owner = try values.decode(String.self, forKey: .owner)
        let balance = try values.decode(IntOrString.self, forKey: .balance)
        switch balance {
        case .integer(let intValue):
            self.balance = intValue
        case .string(let stringValue):
            if let intValue = Int(stringValue) {
                self.balance = intValue
            } else {
                throw ECHOError.encodableMapping
            }
        }
    }
}
