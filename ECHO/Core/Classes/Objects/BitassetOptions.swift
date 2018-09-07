//
//  BitassetOptions.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 20.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    The bitasset_options struct contains configurable options available only to BitAssets
 
    [BitassetOptions model documentations](https://dev-doc.myecho.app/structgraphene_1_1chain_1_1bitasset__options.html)
 */
public struct BitassetOptions: ECHOCodable, Decodable {
    
    enum BitassetOptionsCodingKeys: String, CodingKey {
        case feedLifetimeSec = "feed_lifetime_sec"
        case minimumFeeds = "minimum_feeds"
        case forceSettlementDelaySec = "force_settlement_delay_sec"
        case forceSettlementOoffsetPercent = "force_settlement_offset_percent"
        case maximumForceSettlementVolume = "maximum_force_settlement_volume"
        case shortBackingAsset = "short_backing_asset"
        case extensions
    }
    
    let feedLifetimeSec: Int
    let minimumFeeds: Int
    let forceSettlementDelaySec: Int
    let forceSettlementOffsetPercent: Int
    let maximumForceSettlementVolume: Int
    let shortBackingAsset: String
    let extensions: Extensions = Extensions()
    
    public init(feedLifetimeSec: Int,
                minimumFeeds: Int,
                forceSettlementDelaySec: Int,
                forceSettlementOffsetPercent: Int,
                maximumForceSettlementVolume: Int,
                shortBackingAsset: String) {
        
        self.feedLifetimeSec = feedLifetimeSec
        self.minimumFeeds = minimumFeeds
        self.forceSettlementDelaySec = forceSettlementDelaySec
        self.forceSettlementOffsetPercent = forceSettlementOffsetPercent
        self.maximumForceSettlementVolume = maximumForceSettlementVolume
        self.shortBackingAsset = shortBackingAsset
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: BitassetOptionsCodingKeys.self)
        feedLifetimeSec = try values.decode(Int.self, forKey: .feedLifetimeSec)
        minimumFeeds = try values.decode(Int.self, forKey: .minimumFeeds)
        forceSettlementDelaySec = try values.decode(Int.self, forKey: .forceSettlementDelaySec)
        forceSettlementOffsetPercent = try values.decode(Int.self, forKey: .forceSettlementOoffsetPercent)
        maximumForceSettlementVolume = try values.decode(Int.self, forKey: .maximumForceSettlementVolume)
        shortBackingAsset = try values.decode(String.self, forKey: .shortBackingAsset)
    }
    
    // MARK: ECHOCodable
    
    func toJSON() -> Any? {
        
        let dictionary: [AnyHashable: Any?] = [BitassetOptionsCodingKeys.feedLifetimeSec.rawValue: feedLifetimeSec,
                                               BitassetOptionsCodingKeys.minimumFeeds.rawValue: minimumFeeds,
                                               BitassetOptionsCodingKeys.forceSettlementDelaySec.rawValue: forceSettlementDelaySec,
                                               BitassetOptionsCodingKeys.forceSettlementOoffsetPercent.rawValue: forceSettlementOffsetPercent,
                                               BitassetOptionsCodingKeys.maximumForceSettlementVolume.rawValue: maximumForceSettlementVolume,
                                               BitassetOptionsCodingKeys.shortBackingAsset.rawValue: shortBackingAsset,
                                               BitassetOptionsCodingKeys.extensions.rawValue: extensions.toJSON()]
        
        return dictionary
    }
    
    func toData() -> Data? {
        
        var data = Data()
        data.append(optional: Data.fromInt32(feedLifetimeSec))
        data.append(optional: Data.fromInt8(minimumFeeds))
        data.append(optional: Data.fromInt32(forceSettlementDelaySec))
        data.append(optional: Data.fromInt16(forceSettlementOffsetPercent))
        data.append(optional: Data.fromInt16(maximumForceSettlementVolume))
        
        let asset = Asset(shortBackingAsset)
        if let instance = asset.getInstance() {
            data.append(optional: Data.fromUIntLikeUnsignedByteArray(instance))
        }
        
        data.append(optional: extensions.toData())
        
        return data
    }
}
