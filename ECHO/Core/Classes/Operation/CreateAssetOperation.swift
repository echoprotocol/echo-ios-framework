//
//  CreateAssetOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 22.08.2018.
//

struct CreateAssetOperation: BaseOperation {
    
    let defaultAssetId: String = "1.3.1"
    
    enum CreateAssetOperationCodingKeys: String, CodingKey {
        case commonOptions = "common_options"
        case extensions
        case fee
    }
    
    let type: OperationType
    let extensions: Extensions = Extensions()
    var fee: AssetAmount
    
    var asset: Asset
    
    init(from decoder: Decoder) throws {
        
        type = .assetCreateOperation
        
        let values = try decoder.container(keyedBy: CreateAssetOperationCodingKeys.self)
        
        asset = try Asset(from: decoder)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
    }
    
    mutating func changeIssuer(_ account: Account?) {
        
        asset.issuer = account
    }
    
    // MARK: ECHOCodable
    
    func toData() -> Data? {
        
        var data = Data()
        data.append(optional: fee.toData())
        data.append(optional: asset.toData())
        data.append(optional: extensions.toData())
        return data
    }
    
    func toJSON() -> Any? {
        
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
        
        return array
    }
}
