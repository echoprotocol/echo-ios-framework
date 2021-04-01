//
//  ContractInternalCallOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 27/03/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the [OperationType.contractInternalCallOperation](OperationType.contractInternalCallOperation)
    Operation will be visible only when contract call anouher contract or transfer amount to account
 */
public struct ContractInternalCallOperation: BaseOperation {
    
    enum ContractInternalCallOperationCodingKeys: String, CodingKey {
        case value
        case caller
        case callee
        case method
        case extensions
    }
    
    public var type: OperationType
    public var extensions: Extensions = Extensions()
    public var fee: AssetAmount = AssetAmount(amount: 0, asset: Asset(Settings.defaultAsset))
    
    public var caller: Contract
    public var callee: String
    public var value: AssetAmount
    public var method: String
    
    init(caller: Contract, callee: String, value: AssetAmount, method: String) {
        
        self.type = .contractInternalCallOperation
        
        self.caller = caller
        self.callee = callee
        self.value = value
        self.method = method
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .contractInternalCallOperation
        
        let values = try decoder.container(keyedBy: ContractInternalCallOperationCodingKeys.self)
        
        let callerId = try values.decode(String.self, forKey: .caller)
        callee = try values.decode(String.self, forKey: .callee)
        caller = Contract(id: callerId)
        
        value = try values.decode(AssetAmount.self, forKey: .value)
        method = try values.decode(String.self, forKey: .method)
    }
    
    mutating func changeAssets(valueAsset: Asset?, feeAsset: Asset?) {
        if let feeAsset = feeAsset { self.fee = AssetAmount(amount: self.fee.amount, asset: feeAsset) }
        if let valueAsset = valueAsset { self.value = AssetAmount(amount: self.value.amount, asset: valueAsset) }
    }
    
    // MARK: ECHOCodable
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        let dictionary: [AnyHashable: Any?] = [ContractInternalCallOperationCodingKeys.callee.rawValue: callee,
                                               ContractInternalCallOperationCodingKeys.caller.rawValue: caller.toJSON(),
                                               ContractInternalCallOperationCodingKeys.value.rawValue: value.toJSON(),
                                               ContractInternalCallOperationCodingKeys.method.rawValue: method,
                                               ContractInternalCallOperationCodingKeys.extensions.rawValue: extensions.toJSON()]
        
        array.append(dictionary)
        
        return array
    }
    
    public func toJSON() -> String? {
        
        let json: Any? = toJSON()
        let jsonString = (json as? [Any])
            .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: []) }
            .flatMap { String(data: $0, encoding: .utf8) }
        
        return jsonString
    }
    
    public func toData() -> Data? {
        
        // It's virtual operation. No need to serialize to Data
        return nil
    }
}
