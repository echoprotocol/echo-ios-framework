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
        case code
        case fee
        case extensions
    }
    
    public var type: OperationType
    public var extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var registrar: Account
    public var value: AssetAmount
    public let code: String
    public let callee: Contract
    
    public init(registrar: Account,
                value: AssetAmount,
                gasPrice: Int,
                gas: Int,
                code: String,
                callee: Contract,
                fee: AssetAmount) {
        
        self.type = .contractCallOperation
        self.registrar = registrar
        self.value = value
        self.code = code
        self.fee = fee
        self.callee = callee
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .contractCallOperation
        
        let values = try decoder.container(keyedBy: CallContractOperationCodingKeys.self)
        let registrarId = try values.decode(String.self, forKey: .registrar)
        registrar = Account(registrarId)
        
        value = try values.decode(AssetAmount.self, forKey: .value)
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
        
        data.append(optional: Data.fromUIntLikeUnsignedByteArray(UInt(code.count)))
        data.append(optional: code.data(using: .utf8))
        
        data.append(optional: callee.toData())
        data.append(optional: extensions.toData())
        
        return data
    }
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        let dictionary: [AnyHashable: Any?] = [CallContractOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               CallContractOperationCodingKeys.registrar.rawValue: registrar.toJSON(),
                                               CallContractOperationCodingKeys.value.rawValue: value.toJSON(),
                                               CallContractOperationCodingKeys.code.rawValue: code,
                                               CallContractOperationCodingKeys.callee.rawValue: callee.toJSON(),
                                               CallContractOperationCodingKeys.extensions.rawValue: extensions.toJSON()]
        
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
