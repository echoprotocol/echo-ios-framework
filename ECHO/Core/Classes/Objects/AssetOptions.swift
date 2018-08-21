//
//  AssetOptions.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct AssetOptions: ECHOCodable, Decodable {
    
    enum AssetCodingKeys: String, CodingKey {
        case maxSupply = "max_supply"
        case marketFeePercent = "market_fee_percent"
        case maxMarketFee = "max_market_fee"
        case flags
        case issuerPermissions = "issuer_permissions"
        case coreExchangRate = "core_exchange_rate"
        case description
        case extensions
        case whitelistAuthorities = "whitelist_authorities"
        case blacklistAuthorities = "blacklist_authorities"
        case whitelistMarkets = "whitelistMarkets"
        case blacklistMarkets = "blacklist_markets"
    }
    
    let maxSupply: UInt
    let marketFeePercent: Int
    let maxMarketFee: UInt
    let issuerPermissions: Int
    let flags: Int
    var coreExchangeRate = [Price]()
    let description: String?
    let whitelistAuthorities: Set<Account>
    let blacklistAuthorities: Set<Account>
    let whitelistMarkets: Set<Account>
    let blacklistMarkets: Set<Account>
    let extensions = Extensions()
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: AssetCodingKeys.self)
        maxSupply = try values.decode(UInt.self, forKey: .maxSupply)
        marketFeePercent = try values.decode(Int.self, forKey: .marketFeePercent)
        maxMarketFee = try values.decode(UInt.self, forKey: .maxMarketFee)
        issuerPermissions = try values.decode(Int.self, forKey: .issuerPermissions)
        flags = try values.decode(Int.self, forKey: .flags)
        description = try values.decode(String.self, forKey: .description)
        let coreExchangeRateValue = try values.decode(Price.self, forKey: .coreExchangRate)
        coreExchangeRate.append(coreExchangeRateValue)
        
        whitelistAuthorities = try values.decode(Set<Account>.self, forKey: .whitelistAuthorities)
        blacklistAuthorities = try values.decode(Set<Account>.self, forKey: .blacklistAuthorities)
        whitelistMarkets = try values.decode(Set<Account>.self, forKey: .whitelistMarkets)
        blacklistMarkets = try values.decode(Set<Account>.self, forKey: .blacklistMarkets)
    }
    
    // MARK: ECHOCodable
    
    func toJSON() -> Any? {
        
        var whitelistAuthoritiesArray = [Any?]()
        whitelistAuthorities.forEach {
            whitelistAuthoritiesArray.append($0.id)
        }
        
        var blacklistAuthoritiesArray = [Any?]()
        blacklistAuthorities.forEach {
            blacklistAuthoritiesArray.append($0.id)
        }
        
        var whitelistMarketsArray = [Any?]()
        whitelistMarkets.forEach {
            whitelistMarketsArray.append($0.id)
        }
        
        var blacklistMarketsArray = [Any?]()
        blacklistMarkets.forEach {
            blacklistMarketsArray.append($0.id)
        }
        
        let dictionary: [AnyHashable: Any?] = [AssetCodingKeys.maxSupply.rawValue: maxSupply,
                                               AssetCodingKeys.marketFeePercent.rawValue: marketFeePercent,
                                               AssetCodingKeys.maxMarketFee.rawValue: maxMarketFee,
                                               AssetCodingKeys.issuerPermissions.rawValue: issuerPermissions,
                                               AssetCodingKeys.flags.rawValue: flags,
                                               AssetCodingKeys.coreExchangRate.rawValue: coreExchangeRate[safe: 0]?.toJSON(),
                                               AssetCodingKeys.whitelistAuthorities.rawValue: whitelistAuthoritiesArray,
                                               AssetCodingKeys.blacklistAuthorities.rawValue: blacklistAuthoritiesArray,
                                               AssetCodingKeys.whitelistMarkets.rawValue: whitelistMarketsArray,
                                               AssetCodingKeys.blacklistMarkets.rawValue: blacklistMarketsArray,
                                               AssetCodingKeys.description.rawValue: description ?? "",
                                               AssetCodingKeys.extensions.rawValue: extensions.toJSON()]
        
        return dictionary
    }
    
    func toData() -> Data? {
        
        var data = Data()
        data.append(optional: Data.fromInt64(maxSupply))
        data.append(optional: Data.fromInt16(marketFeePercent))
        data.append(optional: Data.fromInt64(maxMarketFee))
        data.append(optional: Data.fromInt16(issuerPermissions))
        data.append(optional: Data.fromInt16(flags))
        data.append(optional: coreExchangeRate[safe: 0]?.toData())
        
        let whitelistAuthoritiesData = Data.fromSet(whitelistAuthorities) {
            return $0.toData()
        }
        data.append(optional: whitelistAuthoritiesData)
        
        let blacklistAuthoritiesData = Data.fromSet(blacklistAuthorities) {
            return $0.toData()
        }
        data.append(optional: blacklistAuthoritiesData)
        
        let whitelistMarketsData = Data.fromSet(whitelistMarkets) {
            return $0.toData()
        }
        data.append(optional: whitelistMarketsData)
        
        let blacklistMarketsData = Data.fromSet(blacklistMarkets) {
            return $0.toData()
        }
        data.append(optional: blacklistMarketsData)
    
        data.append(optional: Data.fromString(description))
        data.append(optional: extensions.toData())
        
        return data
    }
}
