//
//  Authority.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

class Authority: Decodable {
    
    enum AuthorityCodingKeys: String, CodingKey {
        case weightThreshold = "weight_threshold"
        case accountAuths = "account_auths"
        case keyAuths = "key_auths"
        case addressAuths = "address_auths"
    }
    
    var weightThreshold: Int
    var accountAuths: [Account]
    var keyAuths: [[IntOrString]]
    var addressAuths: [Any] = [Any]()
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: AuthorityCodingKeys.self)
        weightThreshold = try values.decode(Int.self, forKey: .weightThreshold)
        accountAuths = try values.decode([Account].self, forKey: .accountAuths)
        keyAuths = try values.decode([[IntOrString]].self, forKey: .keyAuths)
    }
}
