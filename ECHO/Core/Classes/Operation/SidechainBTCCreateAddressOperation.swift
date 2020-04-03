//
//  SidechainBTCCreateAddressOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 28.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the
    [OperationType.SidechainBTCCreateAddressOperation](OperationType.SidechainBTCCreateAddressOperation)
 */
public struct SidechainBTCCreateAddressOperation: BaseOperation {
    
    enum SidechainBTCCreateAddressOperationCodingKeys: String, CodingKey {
        case account
        case backupAddress = "backup_address"
        case extensions
        case fee
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var account: Account
    public var backupAddress: String
    
    init(account: Account, backupAddress: String, fee: AssetAmount) {
        
        type = .sidechainBTCCreateAddressOperation
        
        self.account = account
        self.fee = fee
        self.backupAddress = backupAddress
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .sidechainBTCCreateAddressOperation
        
        let values = try decoder.container(keyedBy: SidechainBTCCreateAddressOperationCodingKeys.self)
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
        backupAddress = try values.decode(String.self, forKey: .backupAddress)
    }
    
    mutating func changeAccount(account: Account?) {
        
        if let account = account { self.account = account }
    }
    
    mutating func changeAssets(feeAsset: Asset?) {
        
        if let feeAsset = feeAsset { self.fee = AssetAmount(amount: fee.amount, asset: feeAsset) }
    }
    
    // MARK: ECHOCodable
    
    public func toData() -> Data? {
        
        var data = Data()
        
        data.append(optional: fee.toData())
        data.append(optional: account.toData())
        data.append(optional: Data.fromString(backupAddress))
        data.append(optional: extensions.toData())

        return data
    }
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        let dictionary: [AnyHashable: Any?] = [SidechainBTCCreateAddressOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               SidechainBTCCreateAddressOperationCodingKeys.account.rawValue: account.toJSON(),
                                               SidechainBTCCreateAddressOperationCodingKeys.backupAddress.rawValue: backupAddress,
                                               SidechainBTCCreateAddressOperationCodingKeys.extensions.rawValue: extensions.toJSON()]
        
        array.append(dictionary)
        
        return array
    }
}
