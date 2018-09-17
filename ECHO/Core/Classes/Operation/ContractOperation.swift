//
//  ContractOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 11.09.2018.
//

/**
    Struct used to encapsulate operations related to the [OperationType.contractOperation](OperationType.contractOperation)
 */
struct ContractOperation: BaseOperation {
    
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
    
    var type: OperationType
    var extensions: Extensions = Extensions()
    var fee: AssetAmount
    
    let registrar: Account
    let asset: Asset
    let value: Int
    let gasPrice: Int
    let gas: Int
    let code: String
    let receiver: OptionalValue<Contract>
    
    public init(registrar: Account,
                asset: Asset,
                value: Int,
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
        value = try values.decode(Int.self, forKey: .value)
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
    
    func toData() -> Data? {
        
        var data = Data()
        data.append(optional: fee.toData())
        data.append(optional: registrar.toData())
        data.append(optional: receiver.toData())
        if let instance = asset.getInstance() {
            data.append(optional: Data.fromUIntLikeUnsignedByteArray(instance))
        }
        data.append(optional: Data.fromInt64(value))
        data.append(optional: Data.fromInt64(gasPrice))
        data.append(optional: Data.fromInt64(gas))
        
        data.append(optional: Data.fromUIntLikeUnsignedByteArray(UInt(code.count)))
        data.append(optional: code.data(using: .utf8))
        
        return data
    }
    
    func toJSON() -> Any? {
        
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
}
