//
//  Asset.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Class used to represent a specific asset on the Graphene platform
 
    [Asset model documentation](https://dev-doc.myecho.app/structgraphene_1_1chain_1_1asset.html)
 */
public struct Asset: ECHOObject, Decodable {
    
    enum AssetCodingKeys: String, CodingKey {
        case issuer
        case precision
        case symbol
        case dynamicAssetDataId = "dynamic_asset_data_id"
        case commonOptions = "common_options"
        case options
        case bitassetDataId = "bitasset_data_id"
        case bitassetOpts = "bitasset_opts"
        case id
    }
    
    public var id: String
    public var symbol: String?
    public var precision: Int = -1
    public var issuer: Account?
    public var dynamicAssetDataId: String?
    public var options: AssetOptions?
    public var bitAssetId: String?
    var bitassetOptions: OptionalValue<BitassetOptions>
    
    public init(_ id: String) {
        
        self.id = id
        bitassetOptions = OptionalValue(nil, addByteToStart: true)
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: AssetCodingKeys.self)
        if values.contains(.id) {
            id = try values.decode(String.self, forKey: .id)
        } else {
            id = ""
        }
        symbol = try values.decode(String.self, forKey: .symbol)
        precision = try values.decode(Int.self, forKey: .precision)
        let issuerId = try values.decode(String.self, forKey: .issuer)
        issuer = Account(issuerId)
        dynamicAssetDataId = try? values.decode(String.self, forKey: .dynamicAssetDataId)
        if values.contains(.options) {
            options = try? values.decode(AssetOptions.self, forKey: .options)
        } else {
            options = try? values.decode(AssetOptions.self, forKey: .commonOptions)
        }
        let parsedBitassetOpt = try? values.decode(BitassetOptions.self, forKey: .bitassetOpts)
        bitassetOptions = OptionalValue(parsedBitassetOpt, addByteToStart: true)
        bitAssetId = try? values.decode(String.self, forKey: .bitassetDataId)
    }
    
    public mutating func setBitsassetOptions(_ options: BitassetOptions) {
        
        bitassetOptions = OptionalValue<BitassetOptions>(options, addByteToStart: true)
    }
    
    // MARK: BytesCodable
    
    public func toData() -> Data? {
        
        var data = Data()
        data.append(optional: issuer?.toData())
        data.append(optional: Data.fromString(symbol))
        data.append(optional: Data.fromInt8(precision))
        data.append(optional: options?.toData())
        data.append(optional: bitassetOptions.toData())
        return data
    }
}
