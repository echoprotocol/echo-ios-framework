//
//  ContractFundPoolOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 02.12.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the
    [OperationType.contractFundPoolOperation](OperationType.contractFundPoolOperation)
 */
public struct ContractFundPoolOperation: BaseOperation {
    
    enum ContractFundPoolOperationCodingKeys: String, CodingKey {
        case sender
        case contract
        case value
        case fee
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var sender: Account
    public let contract: Contract
    public var value: AssetAmount
    
    public init(from decoder: Decoder) throws {
        
        type = .contractFundPoolOperation
        
        let values = try decoder.container(keyedBy: ContractFundPoolOperationCodingKeys.self)
        
        let senderId = try values.decode(String.self, forKey: .sender)
        sender = Account(senderId)
        
        let contractId = try values.decode(String.self, forKey: .contract)
        contract = Contract(id: contractId)
        
        value = try values.decode(AssetAmount.self, forKey: .value)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
    }
    
    mutating func changeSender(account: Account?) {
        
        if let account = account { self.sender = account }
    }
    
    mutating func changeAssets(valueAsset: Asset?, feeAsset: Asset?) {
        
        if let valueAsset = valueAsset { self.value = AssetAmount(amount: value.amount, asset: valueAsset) }
        if let feeAsset = feeAsset { self.fee = AssetAmount(amount: fee.amount, asset: feeAsset) }
    }
    
    // MARK: ECHOCodable
    // Not used to transfer by user
    
    public func toData() -> Data? {
        
        return nil
    }
    
    public func toJSON() -> Any? {
        
        return nil
    }
}
