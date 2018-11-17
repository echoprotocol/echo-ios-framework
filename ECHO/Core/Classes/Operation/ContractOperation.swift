//
//  ContractOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 11.09.2018.
//

/**
    Struct used to encapsulate operations related to the [OperationType.contractOperation](OperationType.contractOperation)
 */
public struct ContractOperation: BaseOperation {
    
    private enum ContractOperationCodingKeys: String, CodingKey {
        case registrar
        case receiver
        case value
        case gasPrice
        case gas
        case code
        case assetId = "asset_id"
        case fee
    }
    
    public var type: OperationType
    public var extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public let registrar: Account
    public var asset: Asset
    public let value: UInt
    public let gasPrice: Int
    public let gas: Int
    public let code: String
    public let receiver: OptionalValue<Contract>
    
    public init(registrar: Account,
                asset: Asset,
                value: UInt,
                gasPrice: Int,
                gas: Int,
                code: String,
                receiver: Contract?,
                fee: AssetAmount) {
        
        self.type = .contractOperation
        self.registrar = registrar
        self.asset = asset
        self.value = value
        self.gasPrice = gasPrice
        self.gas = gas
        self.code = code
        self.fee = fee
        self.receiver = OptionalValue<Contract>(receiver, addByteToStart: true)
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .contractOperation
        
        let values = try decoder.container(keyedBy: ContractOperationCodingKeys.self)
        let registrarId = try values.decode(String.self, forKey: .registrar)
        registrar = Account(registrarId)
        let assetId = try values.decode(String.self, forKey: .assetId)
        asset = Asset(assetId)
        value = try values.decode(UInt.self, forKey: .value)
        gasPrice = try values.decode(Int.self, forKey: .gasPrice)
        gas = try values.decode(Int.self, forKey: .gas)
        code = try values.decode(String.self, forKey: .code)
        if let recieverContractId = try? values.decode(String.self, forKey: .receiver) {
            let contract = Contract(id: recieverContractId)
            receiver = OptionalValue<Contract>(contract, addByteToStart: true)
        } else {
            receiver = OptionalValue<Contract>(nil, addByteToStart: true)
        }
        
        fee = try values.decode(AssetAmount.self, forKey: .fee)
    }
    
    public func toData() -> Data? {
        
        var data = Data()
        data.append(optional: fee.toData())
        data.append(optional: registrar.toData())
        data.append(optional: receiver.toData())
        if let instance = asset.getInstance() {
            data.append(optional: Data.fromUIntLikeUnsignedByteArray(instance))
        }
        data.append(optional: Data.fromUint64(value))
        data.append(optional: Data.fromInt64(gasPrice))
        data.append(optional: Data.fromInt64(gas))
        
        data.append(optional: Data.fromUIntLikeUnsignedByteArray(UInt(code.count)))
        data.append(optional: code.data(using: .utf8))
        
        return data
    }
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        var dictionary: [AnyHashable: Any?] = [ContractOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               ContractOperationCodingKeys.registrar.rawValue: registrar.toJSON(),
                                               ContractOperationCodingKeys.assetId.rawValue: asset.toJSON(),
                                               ContractOperationCodingKeys.value.rawValue: value,
                                               ContractOperationCodingKeys.gasPrice.rawValue: gasPrice,
                                               ContractOperationCodingKeys.gas.rawValue: gas,
                                               ContractOperationCodingKeys.code.rawValue: code]
        
        if receiver.isSet() {
            dictionary[ContractOperationCodingKeys.receiver.rawValue] = receiver.toJSON()
        }
        
        array.append(dictionary)
        
        return array
    }
    
    mutating func changeAssets(feeAsset: Asset?, asset: Asset?) {
        
        if let feeAsset = feeAsset { self.fee = AssetAmount(amount: fee.amount, asset: feeAsset) }
        if let asset = asset { self.asset = asset }
    }
}
