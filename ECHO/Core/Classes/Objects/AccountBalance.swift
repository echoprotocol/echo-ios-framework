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
    
    let assetType: String
    let owner: String
    let balance: Int

    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: AccountBalanceCodingKeys.self)
        let id = try values.decode(String.self, forKey: .id)
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
        super.init(string: id)
    }
}
