//
//  Фссщгте.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

public struct Account: ECHOObject, Decodable {
    
    enum AccountCodingKeys: String, CodingKey {
        case id
        case membershiExperationDate = "membership_expiration_date"
        case registrar
        case referrer
        case lifetimeReferrer = "lifetime_referrer"
        case networkFeePercentage = "network_fee_percentage"
        case lifetimeReferrerFeePercentage = "lifetime_referrer_fee_percentage"
        case referrerRewardsPercentage = "referrer_rewards_percentage"
        case name
        case owner
        case active
        case options
        case statistics
    }
    
    public let id: String
    public let membershiExperationDate: String
    public let registrarId: String
    public let referrerId: String
    public let lifetimeReferrer: String
    public let networkFeePercentage: Int
    public let lifetimeReferrerFeePercentage: Int
    public let referrerRewardsPercentage: Int
    public let name: String
    public let owner: Authority
    public let active: Authority
    public let options: Options
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: AccountCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        membershiExperationDate = try values.decode(String.self, forKey: .membershiExperationDate)
        registrarId = try values.decode(String.self, forKey: .registrar)
        referrerId = try values.decode(String.self, forKey: .referrer)
        lifetimeReferrer = try values.decode(String.self, forKey: .lifetimeReferrer)
        networkFeePercentage = try values.decode(Int.self, forKey: .networkFeePercentage)
        lifetimeReferrerFeePercentage = try values.decode(Int.self, forKey: .lifetimeReferrerFeePercentage)
        referrerRewardsPercentage = try values.decode(Int.self, forKey: .referrerRewardsPercentage)
        name = try values.decode(String.self, forKey: .name)
        owner = try values.decode(Authority.self, forKey: .owner)
        active = try values.decode(Authority.self, forKey: .active)
        options = try values.decode(Options.self, forKey: .options)
    }
}
