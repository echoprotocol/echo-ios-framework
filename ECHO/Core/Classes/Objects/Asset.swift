//
//  Asset.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Class used to represent a specific asset on the Graphene platform
 */
public struct Asset: ECHOObject, BytesCodable, Decodable {
    
    enum AssetCodingKeys: String, CodingKey {
        case issuer
        case precision
        case symbol
        case dynamicAssetDataId = "dynamic_asset_data_id"
        case options
        case bitassetDataId = "bitasset_data_id"
        case bitassetOpts = "bitasset_opts"
        case isPredictionMarket = "is_prediction_market"
        case id
    }
    
    var id: String
    var symbol: String?
    var precision: Int = -1
    var issuer: Account?
    var dynamicAssetDataId: String?
    var options: AssetOptions?
    var bitassetOptions: OptionalValue<BitassetOptions>
    var predictionMarket: Bool = false
    var bitAssetId: String?
    
    init(_ id: String) {
        
        self.id = id
        bitassetOptions = OptionalValue(nil)
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: AssetCodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        symbol = try values.decode(String.self, forKey: .symbol)
        precision = try values.decode(Int.self, forKey: .precision)
        let issuerId = try values.decode(String.self, forKey: .issuer)
        issuer = Account(issuerId)
        dynamicAssetDataId = try values.decode(String.self, forKey: .dynamicAssetDataId)
        options = try values.decode(AssetOptions.self, forKey: .options)
        let parsedBitassetOpt = try? values.decode(BitassetOptions.self, forKey: .bitassetOpts)
        bitassetOptions = OptionalValue(parsedBitassetOpt)
        predictionMarket = (try? values.decode(Bool.self, forKey: .isPredictionMarket)) ?? false
        bitAssetId = try? values.decode(String.self, forKey: .bitassetDataId)
    }
    
    // MARK: BytesCodable
    
    func toData() -> Data? {
        
        var data = Data()
        data.append(optional: issuer?.toData())
        data.append(optional: Data.fromString(symbol))
        data.append(optional: Data.fromInt8(precision))
        data.append(optional: options?.toData())
        data.append(optional: bitassetOptions.toData())
        data.append(optional: Data.fromBool(predictionMarket))
        return data
    }
}
