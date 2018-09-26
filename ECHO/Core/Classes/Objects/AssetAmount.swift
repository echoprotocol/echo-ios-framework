//
//  AssetAmount.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Class used to represent a specific amount of a certain asset
 */
public struct AssetAmount: ECHOCodable, Decodable {
    
    enum AssetAmountCodingKeys: String, CodingKey {
        case amount
        case assetId = "asset_id"
    }
    
    public let amount: UInt
    public let asset: Asset
    
    public init(amount: UInt, asset: Asset) {
        
        self.amount = amount
        self.asset = asset
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: AssetAmountCodingKeys.self)
        amount = try values.decode(UInt.self, forKey: .amount)
        let assetId = try values.decode(String.self, forKey: .assetId)
        asset = Asset(assetId)
    }
    
    // MARK: ECHOCodable
    
    func toJSON() -> Any? {
        
        let dictionary: [AnyHashable: Any?] = [AssetAmountCodingKeys.amount.rawValue: amount,
                                               AssetAmountCodingKeys.assetId.rawValue: asset.id]
        
        return dictionary
    }
    
    func toData() -> Data? {
        
        guard let assetInstance = asset.getInstance() else {
            return nil
        }
        
        var data = Data()
        data.append(optional: Data.fromUint64(amount))
        data.append(optional: Data.fromUIntLikeUnsignedByteArray(assetInstance))
        return data
    }
}
