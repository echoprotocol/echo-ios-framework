//
//  TransferOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 22.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the [OperationType.transferOperation](OperationType.transferOperation)
 */
public struct TransferOperation: BaseOperation {
    
    enum TransferOperationCodingKeys: String, CodingKey {
        case amount
        case fromAccount = "from"
        case toAccount = "to"
        case memo
        case extensions
        case fee
    }
    
    public var type: OperationType
    public var extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var fromAccount: Account
    public var toAccount: Account
    public var transferAmount: AssetAmount
    public var memo: Memo = Memo()
    
    init(fromAccount: Account, toAccount: Account, transferAmount: AssetAmount, fee: AssetAmount, memo: Memo?) {
        
        self.type = .transferOperation
        
        self.fromAccount = fromAccount
        self.toAccount = toAccount
        self.transferAmount = transferAmount
        self.fee = fee
        if let memo = memo {
            self.memo = memo
        }
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .transferOperation
        
        let values = try decoder.container(keyedBy: TransferOperationCodingKeys.self)
        
        let fromId = try values.decode(String.self, forKey: .fromAccount)
        let toId = try values.decode(String.self, forKey: .toAccount)
        fromAccount = Account(fromId)
        toAccount = Account(toId)
        
        transferAmount = try values.decode(AssetAmount.self, forKey: .amount)
        fee = try values.decode(AssetAmount.self, forKey: .fee)

        if values.contains(.memo) {
            memo = try values.decode(Memo.self, forKey: .memo)
        }
    }
    
    mutating func changeAccounts(from: Account?, toAccount: Account?) {
        
        if let from = from { self.fromAccount = from }
        if let toAccount = toAccount { self.toAccount = toAccount }
    }
    
    // MARK: ECHOCodable
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        var dictionary: [AnyHashable: Any?] = [TransferOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               TransferOperationCodingKeys.fromAccount.rawValue: fromAccount.toJSON(),
                                               TransferOperationCodingKeys.toAccount.rawValue: toAccount.toJSON(),
                                               TransferOperationCodingKeys.amount.rawValue: transferAmount.toJSON(),
                                               TransferOperationCodingKeys.extensions.rawValue: extensions.toJSON()]
        
        if memo.byteMessage != nil {
            dictionary[TransferOperationCodingKeys.memo.rawValue] = memo.toJSON()
        }
        
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
        data.append(optional: fromAccount.toData())
        data.append(optional: toAccount.toData())
        data.append(optional: transferAmount.toData())
        data.append(optional: memo.toData())
        data.append(optional: extensions.toData())
        return data
    }
}
