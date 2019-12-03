//
//  SidechainBTCWithdrawOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 28.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the
    [OperationType.sidechainBTCWithdrawOperation](OperationType.sidechainBTCWithdrawOperation)
 */
public struct SidechainBTCWithdrawOperation: BaseOperation {
    
    enum SidechainBTCWithdrawOperationCodingKeys: String, CodingKey {
        case account = "account"
        case btcAddress = "btc_addr"
        case value
        case extensions
        case fee
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var account: Account
    public let btcAddress: String
    public let value: UInt
    
    init(account: Account, value: UInt, btcAddress: String, fee: AssetAmount) {
        
        type = .sidechainBTCWithdrawOperation
        
        self.account = account
        self.fee = fee
        self.value = value
        self.btcAddress = btcAddress
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .sidechainBTCWithdrawOperation
        
        let values = try decoder.container(keyedBy: SidechainBTCWithdrawOperationCodingKeys.self)
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        btcAddress = try values.decode(String.self, forKey: .btcAddress)
        value = try values.decode(UInt.self, forKey: .value)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
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
        data.append(optional: Data.fromString(btcAddress))
        data.append(optional: Data.fromUint64(value))
        data.append(optional: extensions.toData())
        return data
    }
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        let dictionary: [AnyHashable: Any?] = [SidechainBTCWithdrawOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               SidechainBTCWithdrawOperationCodingKeys.account.rawValue: account.toJSON(),
                                               SidechainBTCWithdrawOperationCodingKeys.extensions.rawValue: extensions.toJSON(),
                                               SidechainBTCWithdrawOperationCodingKeys.value.rawValue: value,
                                               SidechainBTCWithdrawOperationCodingKeys.btcAddress.rawValue: btcAddress]
        
        array.append(dictionary)
        
        return array
    }
}
