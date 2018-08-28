//
//  AssetAmount.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public struct AssetAmount: ECHOCodable, Decodable {
    
    enum AssetAmountCodingKeys: String, CodingKey {
        case amount
        case assetId = "asset_id"
    }
    
    let amount: UInt
    let asset: Asset
    
    init(amount: UInt, asset: Asset) {
        
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
        data += Data.fromUIntLikeUnsignedByteArray(assetInstance)
        data += Data.fromUint64(amount)
        return data
    }
}
