//
//  Account.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Represents account model in Graphene blockchain
 
    [Account model documentation](https://dev-doc.myecho.app/classgraphene_1_1chain_1_1account__object.html)
 */
public struct Account: ECHOObject, ECHOCodable, Decodable, Hashable {

    enum AccountCodingKeys: String, CodingKey {
        case id
        case membershipExperationDate = "membership_expiration_date"
        case registrar
        case referrer
        case lifetimeReferrer = "lifetime_referrer"
        case lifetimeReferrerFeePercentage = "lifetime_referrer_fee_percentage"
        case referrerRewardsPercentage = "referrer_rewards_percentage"
        case name
        case active
        case options
        case statistics
        case edKey = "echorand_key"
        case accumulatedReward = "accumulated_reward"
    }
    
    public var id: String
    public var membershipExperationDate: String?
    public var registrarId: String?
    public var referrerId: String?
    public var lifetimeReferrer: String?
    public var lifetimeReferrerFeePercentage: Int?
    public var referrerRewardsPercentage: Int?
    public var name: String?
    public var active: Authority?
    public var options: Options?
    public var edKey: String?
    public var accumulatedReward: UInt?
    
    public init(_ id: String) {
        
        self.id = id
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: AccountCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        membershipExperationDate = try? values.decode(String.self, forKey: .membershipExperationDate)
        registrarId = try? values.decode(String.self, forKey: .registrar)
        referrerId = try? values.decode(String.self, forKey: .referrer)
        lifetimeReferrer = try? values.decode(String.self, forKey: .lifetimeReferrer)
        lifetimeReferrerFeePercentage = try? values.decode(Int.self, forKey: .lifetimeReferrerFeePercentage)
        referrerRewardsPercentage = try? values.decode(Int.self, forKey: .referrerRewardsPercentage)
        name = try? values.decode(String.self, forKey: .name)
        active = try? values.decode(Authority.self, forKey: .active)
        options = try? values.decode(Options.self, forKey: .options)
        edKey = try? values.decode(String.self, forKey: .edKey)
        accumulatedReward = try? values.decode(UInt.self, forKey: .accumulatedReward)
    }
    
    // MARK: Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Account, rhs: Account) -> Bool {
        
        return lhs.id == rhs.id
    }
    
    // MARK: ECHOCodable
    
    public func toJSON() -> Any? {
        return id
    }
    
    public func toJSON() -> String? {
        return id
    }
}
