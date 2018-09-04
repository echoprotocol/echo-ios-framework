//
//  Authority.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

/**
    Class used to represent the weighted set of keys and accounts that must approve operations.
 
    [Authority details](https://dev-doc.myecho.app/structgraphene_1_1chain_1_1authority.html)
 */
public struct Authority: ECHOCodable, Decodable {
    
    enum AuthorityCodingKeys: String, CodingKey {
        case weightThreshold = "weight_threshold"
        case accountAuths = "account_auths"
        case keyAuths = "key_auths"
        case extensions
    }
    
    public let weightThreshold: Int
    public let accountAuths: [AccountAuthority]
    public let keyAuths: [AddressAuthority]
    public let extensions = Extensions()
    
    public init (weight: Int, keyAuth: [AddressAuthority], accountAuth: [AccountAuthority]) {
        
        self.weightThreshold = weight
        self.accountAuths = accountAuth
        self.keyAuths = keyAuth
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: AuthorityCodingKeys.self)
        weightThreshold = try values.decode(Int.self, forKey: .weightThreshold)
        accountAuths = try values.decode([AccountAuthority].self, forKey: .accountAuths)
        keyAuths = try values.decode([AddressAuthority].self, forKey: .keyAuths)
    }
    
    // MARK: ECHOCodable
    
    func toData() -> Data? {
        
        var data = Data()
        
        let authsCount = accountAuths.count + keyAuths.count
        data.append(optional: Data.fromInt8(authsCount))
        
        if authsCount == 0 {
            return data
        }
        
        data.append(optional: Data.fromInt32(weightThreshold))
        
        let accountAuthsData = Data.fromArray(accountAuths) {
            return $0.toData()
        }
        data.append(optional: accountAuthsData)
        
        let addressAuthsData = Data.fromArray(keyAuths) {
            return $0.toData()
        }
        data.append(optional: addressAuthsData)
        
        data.append(optional: Data.fromInt8(extensions.size()))
        
        return data
    }
    
    func toJSON() -> Any? {
        
        var accountsAuthsJSON = [Any?]()
        accountAuths.forEach {
            accountsAuthsJSON.append($0.toJSON())
        }
        
        var keyAuthsJSON = [Any?]()
        keyAuths.forEach {
            keyAuthsJSON.append($0.toJSON())
        }
        
        let dictionary: [AnyHashable: Any?] = [AuthorityCodingKeys.weightThreshold.rawValue: weightThreshold,
                                               AuthorityCodingKeys.keyAuths.rawValue: keyAuthsJSON,
                                               AuthorityCodingKeys.accountAuths.rawValue: accountsAuthsJSON,
                                               AuthorityCodingKeys.extensions.rawValue: extensions.toJSON()]
        
        return dictionary
    }
}
