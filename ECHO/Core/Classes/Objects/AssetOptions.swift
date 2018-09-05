//
//  AssetOptions.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public struct AssetOptions: ECHOCodable, Decodable {
    
    enum AssetOptionsCodingKeys: String, CodingKey {
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
        case whitelistMarkets = "whitelist_markets"
        case blacklistMarkets = "blacklist_markets"
    }
    
    let maxSupply: UInt
    let marketFeePercent: Int
    let maxMarketFee: UInt
    let issuerPermissions: Int
    let flags: Int
    var coreExchangeRate = [Price]()
    let description: String?
    let whitelistAuthorities: [Account]
    let blacklistAuthorities: [Account]
    let whitelistMarkets: [Account]
    let blacklistMarkets: [Account]
    let extensions = Extensions()
    
    public init(maxSupply: UInt,
                marketFeePercent: Int,
                maxMarketFee: UInt,
                issuerPermissions: Int,
                flags: Int,
                coreExchangeRate: Price,
                description: String?) {
        
        self.maxSupply = maxSupply
        self.marketFeePercent = marketFeePercent
        self.maxMarketFee = maxMarketFee
        self.issuerPermissions = issuerPermissions
        self.flags = flags
        self.coreExchangeRate.append(coreExchangeRate)
        self.description = description
        
        self.whitelistAuthorities = [Account]()
        self.blacklistAuthorities = [Account]()
        self.whitelistMarkets = [Account]()
        self.blacklistMarkets = [Account]()
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: AssetOptionsCodingKeys.self)
        maxSupply = UInt(try values.decode(IntOrString.self, forKey: .maxSupply).intValue)
        marketFeePercent = try values.decode(IntOrString.self, forKey: .marketFeePercent).intValue
        maxMarketFee = UInt(try values.decode(IntOrString.self, forKey: .maxMarketFee).intValue)
        issuerPermissions = try values.decode(IntOrString.self, forKey: .issuerPermissions).intValue
        flags = try values.decode(IntOrString.self, forKey: .flags).intValue
        description = try values.decode(String.self, forKey: .description)
        let coreExchangeRateValue = try values.decode(Price.self, forKey: .coreExchangRate)
        coreExchangeRate.append(coreExchangeRateValue)
        
        whitelistAuthorities = try values.decode([Account].self, forKey: .whitelistAuthorities)
        blacklistAuthorities = try values.decode([Account].self, forKey: .blacklistAuthorities)
        whitelistMarkets = try values.decode([Account].self, forKey: .whitelistMarkets)
        blacklistMarkets = try values.decode([Account].self, forKey: .blacklistMarkets)
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
        
        let dictionary: [AnyHashable: Any?] = [AssetOptionsCodingKeys.maxSupply.rawValue: maxSupply,
                                               AssetOptionsCodingKeys.marketFeePercent.rawValue: marketFeePercent,
                                               AssetOptionsCodingKeys.maxMarketFee.rawValue: maxMarketFee,
                                               AssetOptionsCodingKeys.issuerPermissions.rawValue: issuerPermissions,
                                               AssetOptionsCodingKeys.flags.rawValue: flags,
                                               AssetOptionsCodingKeys.coreExchangRate.rawValue: coreExchangeRate[safe: 0]?.toJSON(),
                                               AssetOptionsCodingKeys.whitelistAuthorities.rawValue: whitelistAuthoritiesArray,
                                               AssetOptionsCodingKeys.blacklistAuthorities.rawValue: blacklistAuthoritiesArray,
                                               AssetOptionsCodingKeys.whitelistMarkets.rawValue: whitelistMarketsArray,
                                               AssetOptionsCodingKeys.blacklistMarkets.rawValue: blacklistMarketsArray,
                                               AssetOptionsCodingKeys.description.rawValue: description ?? "",
                                               AssetOptionsCodingKeys.extensions.rawValue: extensions.toJSON()]
        
        return dictionary
    }
    
    func toData() -> Data? {
        
        var data = Data()
        data.append(optional: Data.fromUint64(maxSupply))
        data.append(optional: Data.fromInt16(marketFeePercent))
        data.append(optional: Data.fromUint64(maxMarketFee))
        data.append(optional: Data.fromInt16(issuerPermissions))
        data.append(optional: Data.fromInt16(flags))
        data.append(optional: coreExchangeRate[safe: 0]?.toData())
        
        let whitelistAuthoritiesData = Data.fromArray(whitelistAuthorities) {
            return $0.toData()
        }
        data.append(optional: whitelistAuthoritiesData)
        
        let blacklistAuthoritiesData = Data.fromArray(blacklistAuthorities) {
            return $0.toData()
        }
        data.append(optional: blacklistAuthoritiesData)
        
        let whitelistMarketsData = Data.fromArray(whitelistMarkets) {
            return $0.toData()
        }
        data.append(optional: whitelistMarketsData)
        
        let blacklistMarketsData = Data.fromArray(blacklistMarkets) {
            return $0.toData()
        }
        data.append(optional: blacklistMarketsData)
    
        data.append(optional: Data.fromString(description))
        data.append(optional: extensions.toData())
        
        return data
    }
}
