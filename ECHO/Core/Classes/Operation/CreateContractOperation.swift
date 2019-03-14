//
//  CreateContractOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 16/01/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the [OperationType.createContractOperation](OperationType.createContractOperation)
 */
public struct CreateContractOperation: BaseOperation {
    
    private enum CreateContractOperationCodingKeys: String, CodingKey {
        case registrar
        case value
        case code
        case fee
        case supportedAssetId = "supported_asset_id"
        case ethAccuracy = "eth_accuracy"
    }
    
    public var type: OperationType
    public var extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var registrar: Account
    public var value: AssetAmount
    public let code: String
    public var supportedAsset: OptionalValue<Asset>
    public let ethAccuracy: Bool
    
    public init(registrar: Account,
                value: AssetAmount,
                code: String,
                fee: AssetAmount,
                supportedAsset: Asset?,
                ethAccuracy: Bool) {
        
        self.type = .createContractOperation
        self.registrar = registrar
        self.value = value
        self.code = code
        self.fee = fee
        self.supportedAsset = OptionalValue<Asset>(supportedAsset, addByteToStart: true)
        self.ethAccuracy = ethAccuracy
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .createContractOperation
        
        let values = try decoder.container(keyedBy: CreateContractOperationCodingKeys.self)
        let registrarId = try values.decode(String.self, forKey: .registrar)
        registrar = Account(registrarId)
        
        value = try values.decode(AssetAmount.self, forKey: .value)
        code = try values.decode(String.self, forKey: .code)
        
        fee = try values.decode(AssetAmount.self, forKey: .fee)
        
        if let supportedAssetId = try? values.decode(String.self, forKey: .supportedAssetId) {
            let asset = Asset(supportedAssetId)
            supportedAsset = OptionalValue<Asset>(asset, addByteToStart: true)
        } else {
            supportedAsset = OptionalValue<Asset>(nil, addByteToStart: true)
        }
        
        ethAccuracy = try values.decode(Bool.self, forKey: .ethAccuracy)
    }
    
    public func toData() -> Data? {
        
        var data = Data()
        
        data.append(optional: fee.toData())
        data.append(optional: registrar.toData())
        data.append(optional: value.toData())
        
        data.append(optional: Data.fromUIntLikeUnsignedByteArray(UInt(code.count)))
        data.append(optional: code.data(using: .utf8))
        
        data.append(optional: supportedAsset.toData())
        data.append(optional: Data.fromBool(ethAccuracy))
        
        return data
    }
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        var dictionary: [AnyHashable: Any?] = [CreateContractOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               CreateContractOperationCodingKeys.registrar.rawValue: registrar.toJSON(),
                                               CreateContractOperationCodingKeys.value.rawValue: value.toJSON(),
                                               CreateContractOperationCodingKeys.code.rawValue: code,
                                               CreateContractOperationCodingKeys.ethAccuracy.rawValue: ethAccuracy]
        
        if supportedAsset.isSet() {
            dictionary[CreateContractOperationCodingKeys.supportedAssetId.rawValue] = supportedAsset.toJSON()
        }
        
        array.append(dictionary)
        
        return array
    }
    
    mutating func changeAssets(feeAsset: Asset?, asset: Asset?, supportedAsset: Asset?) {
        
        if let feeAsset = feeAsset { self.fee = AssetAmount(amount: fee.amount, asset: feeAsset) }
        if let asset = asset { self.value = AssetAmount(amount: value.amount, asset: asset) }
        if let supportedAsset = supportedAsset { self.supportedAsset = OptionalValue<Asset>(supportedAsset, addByteToStart: true)}
    }
    
    mutating func changeRegistrar(_ registrar: Account?) {
        
        if let registrar = registrar { self.registrar = registrar }
    }
}
