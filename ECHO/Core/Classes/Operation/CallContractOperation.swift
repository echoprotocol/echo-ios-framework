//
//  CallContractOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 16/01/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the [OperationType.callContractOperation](OperationType.callContractOperation)
 */
public struct CallContractOperation: BaseOperation {
    
    private enum CallContractOperationCodingKeys: String, CodingKey {
        case registrar
        case callee
        case value
        case gasPrice
        case gas
        case code
        case fee
    }
    
    public var type: OperationType
    public var extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var registrar: Account
    public var value: AssetAmount
    public let gasPrice: Int
    public let gas: Int
    public let code: String
    public let callee: Contract
    
    public init(registrar: Account,
                value: AssetAmount,
                gasPrice: Int,
                gas: Int,
                code: String,
                callee: Contract,
                fee: AssetAmount) {
        
        self.type = .callContractOperation
        self.registrar = registrar
        self.value = value
        self.gasPrice = gasPrice
        self.gas = gas
        self.code = code
        self.fee = fee
        self.callee = callee
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .callContractOperation
        
        let values = try decoder.container(keyedBy: CallContractOperationCodingKeys.self)
        let registrarId = try values.decode(String.self, forKey: .registrar)
        registrar = Account(registrarId)
        
        value = try values.decode(AssetAmount.self, forKey: .value)
        gasPrice = try values.decode(Int.self, forKey: .gasPrice)
        gas = try values.decode(Int.self, forKey: .gas)
        code = try values.decode(String.self, forKey: .code)
        
        let recieverContractId = try values.decode(String.self, forKey: .callee)
        let contract = Contract(id: recieverContractId)
        callee = contract
        
        fee = try values.decode(AssetAmount.self, forKey: .fee)
    }
    
    public func toData() -> Data? {
        
        var data = Data()
        data.append(optional: fee.toData())
        data.append(optional: registrar.toData())
        data.append(optional: value.toData())
        data.append(optional: Data.fromInt64(gasPrice))
        data.append(optional: Data.fromInt64(gas))
        
        data.append(optional: Data.fromUIntLikeUnsignedByteArray(UInt(code.count)))
        data.append(optional: code.data(using: .utf8))
        
        data.append(optional: callee.toData())
        
        return data
    }
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        let dictionary: [AnyHashable: Any?] = [CallContractOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               CallContractOperationCodingKeys.registrar.rawValue: registrar.toJSON(),
                                               CallContractOperationCodingKeys.value.rawValue: value.toJSON(),
                                               CallContractOperationCodingKeys.gasPrice.rawValue: gasPrice,
                                               CallContractOperationCodingKeys.gas.rawValue: gas,
                                               CallContractOperationCodingKeys.code.rawValue: code,
                                               CallContractOperationCodingKeys.callee.rawValue: callee.toJSON()]
        
        array.append(dictionary)
        
        return array
    }
    
    mutating func changeAssets(feeAsset: Asset?, asset: Asset?) {
        
        if let feeAsset = feeAsset { self.fee = AssetAmount(amount: fee.amount, asset: feeAsset) }
        if let asset = asset { self.value = AssetAmount(amount: value.amount, asset: asset) }
    }
    
    mutating func changeRegistrar(_ registrar: Account?) {
        
        if let registrar = registrar { self.registrar = registrar }
    }
}
