//
//  CreateAssetOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 22.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the [OperationType.assetCreateOperation](OperationType.assetCreateOperation)
 */
public struct CreateAssetOperation: BaseOperation {
    
    let defaultAssetId: String = "1.3.1"
    
    enum CreateAssetOperationCodingKeys: String, CodingKey {
        case commonOptions = "common_options"
        case extensions
        case fee
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var asset: Asset
    
    init(asset: Asset, fee: AssetAmount) {
        
        type = .assetCreateOperation
        
        self.fee = fee
        self.asset = asset
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .assetCreateOperation
        
        let values = try decoder.container(keyedBy: CreateAssetOperationCodingKeys.self)
        
        asset = try Asset(from: decoder)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
    }
    
    mutating func changeIssuer(_ account: Account?) {
        
        asset.issuer = account
    }
    
    // MARK: ECHOCodable
    
    public func toData() -> Data? {
        
        var data = Data()
        data.append(optional: fee.toData())
        data.append(optional: asset.toData())
        data.append(optional: extensions.toData())
        return data
    }
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        var dictionary: [AnyHashable: Any?] = [CreateAssetOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               CreateAssetOperationCodingKeys.extensions.rawValue: extensions.toJSON()]
        
        dictionary[Asset.AssetCodingKeys.issuer.rawValue] = asset.issuer?.toJSON()
        dictionary[Asset.AssetCodingKeys.symbol.rawValue] = asset.symbol
        dictionary[Asset.AssetCodingKeys.precision.rawValue] = asset.precision
        dictionary[CreateAssetOperationCodingKeys.commonOptions.rawValue] = asset.options?.toJSON()
        if asset.bitassetOptions.isSet() {
            dictionary[Asset.AssetCodingKeys.bitassetOpts.rawValue] = asset.bitassetOptions.toJSON()
        }
        dictionary[Asset.AssetCodingKeys.isPredictionMarket.rawValue] = asset.predictionMarket
        
        array.append(dictionary)
        
        return array
    }
}
