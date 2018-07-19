//
//  Authority.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

public struct Authority: Decodable {
    
    enum AuthorityCodingKeys: String, CodingKey {
        case weightThreshold = "weight_threshold"
        case accountAuths = "account_auths"
        case keyAuths = "key_auths"
        case addressAuths = "address_auths"
    }
    
    public var weightThreshold: Int
    public var accountAuths: [Account]
    public var keyAuths: [[IntOrString]]
    public var addressAuths: [Any] = [Any]()
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: AuthorityCodingKeys.self)
        weightThreshold = try values.decode(Int.self, forKey: .weightThreshold)
        accountAuths = try values.decode([Account].self, forKey: .accountAuths)
        keyAuths = try values.decode([[IntOrString]].self, forKey: .keyAuths)
    }
}
