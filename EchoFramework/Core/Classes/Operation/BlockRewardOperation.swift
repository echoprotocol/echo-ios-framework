//
//  BlockRewardOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 02.12.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the
    [OperationType.blockRewardOperation](OperationType.blockRewardOperation)
 */
public struct BlockRewardOperation: BaseOperation {
    
    enum BlockRewardOperationCodingKeys: String, CodingKey {
        case receiver
        case amount
        case extensions
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var receiver: Account
    public let amount: UIntOrString
    
    public init(from decoder: Decoder) throws {
        
        type = .blockRewardOperation
        
        let values = try decoder.container(keyedBy: BlockRewardOperationCodingKeys.self)
        
        let receiverId = try values.decode(String.self, forKey: .receiver)
        receiver = Account(receiverId)
        amount = try values.decode(UIntOrString.self, forKey: .amount)
        fee = AssetAmount(amount: 0, asset: Asset(Settings.defaultAsset))
    }
    
    mutating func changeReceiver(account: Account?) {
        
        if let account = account { self.receiver = account }
    }
    
    mutating func changeAssets(feeAsset: Asset?) {
        
        if let feeAsset = feeAsset { self.fee = AssetAmount(amount: fee.amount, asset: feeAsset) }
    }
    
    // MARK: ECHOCodable
    // Virtual
    
    public func toData() -> Data? {
        
        return nil
    }
    
    public func toJSON() -> Any? {
        
        return nil
    }
}
