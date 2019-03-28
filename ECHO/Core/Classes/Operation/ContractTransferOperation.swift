//
//  ContractTransferOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 27/03/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the [OperationType.contractTransferOperation](OperationType.contractTransferOperation)
    Operation will be visible only when contract transfer assets to account
 */
public struct ContractTransferOperation: BaseOperation {
    
    enum ContractTransferOperationCodingKeys: String, CodingKey {
        case amount
        case fromContract = "from"
        case toAccount = "to"
        case extensions
        case fee
    }
    
    public var type: OperationType
    public var extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var fromContract: Contract
    public var toAccount: Account
    public var transferAmount: AssetAmount
    
    init(fromContract: Contract, toAccount: Account, transferAmount: AssetAmount, fee: AssetAmount) {
        
        self.type = .contractTransferOperation
        
        self.fromContract = fromContract
        self.toAccount = toAccount
        self.transferAmount = transferAmount
        self.fee = fee
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .contractTransferOperation
        
        let values = try decoder.container(keyedBy: ContractTransferOperationCodingKeys.self)
        
        let fromId = try values.decode(String.self, forKey: .fromContract)
        let toId = try values.decode(String.self, forKey: .toAccount)
        fromContract = Contract(id: fromId)
        toAccount = Account(toId)
        
        transferAmount = try values.decode(AssetAmount.self, forKey: .amount)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
    }
    
    mutating func changeAccounts(toAccount: Account?) {
        
        if let toAccount = toAccount { self.toAccount = toAccount }
    }
    
    mutating func changeAssets(feeAsset: Asset?, transferAmount: Asset?) {
        
        if let feeAsset = feeAsset { self.fee = AssetAmount(amount: fee.amount, asset: feeAsset) }
        if let transferAmount = transferAmount { self.transferAmount = AssetAmount(amount: self.transferAmount.amount, asset: transferAmount) }
    }
    
    // MARK: ECHOCodable
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        let dictionary: [AnyHashable: Any?] = [ContractTransferOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               ContractTransferOperationCodingKeys.fromContract.rawValue: fromContract.toJSON(),
                                               ContractTransferOperationCodingKeys.toAccount.rawValue: toAccount.toJSON(),
                                               ContractTransferOperationCodingKeys.amount.rawValue: transferAmount.toJSON(),
                                               ContractTransferOperationCodingKeys.extensions.rawValue: extensions.toJSON()]
        
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
        
        var data = Data()
        data.append(optional: fee.toData())
        data.append(optional: fromContract.toData())
        data.append(optional: toAccount.toData())
        data.append(optional: transferAmount.toData())
        data.append(optional: extensions.toData())
        return data
    }
}
