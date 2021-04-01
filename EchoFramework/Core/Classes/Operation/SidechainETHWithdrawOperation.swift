//
//  SidechainETHWithdrawOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 20/05/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the
    [OperationType.sidechainETHWithdrawOperation](OperationType.sidechainETHWithdrawOperation)
 */
public struct SidechainETHWithdrawOperation: BaseOperation {
    
    enum SidechainETHWithdrawOperationCodingKeys: String, CodingKey {
        case account = "account"
        case ethAddress = "eth_addr"
        case value
        case extensions
        case fee
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var account: Account
    public let ethAddress: String
    public let value: UInt
    
    init(account: Account, value: UInt, ethAddress: String, fee: AssetAmount) {
        
        type = .sidechainETHWithdrawOperation
        
        self.account = account
        self.fee = fee
        self.value = value
        self.ethAddress = ethAddress
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .sidechainETHWithdrawOperation
        
        let values = try decoder.container(keyedBy: SidechainETHWithdrawOperationCodingKeys.self)
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        ethAddress = try values.decode(String.self, forKey: .ethAddress)
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
        
        let addressData = Data(hex: ethAddress)
        data.append(optional: Data.fromUIntLikeUnsignedByteArray(UInt(addressData?.count ?? 0)))
        data.append(optional: addressData)
        
        data.append(optional: Data.fromUint64(value))
        data.append(optional: extensions.toData())
        return data
    }
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        let dictionary: [AnyHashable: Any?] = [SidechainETHWithdrawOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               SidechainETHWithdrawOperationCodingKeys.account.rawValue: account.toJSON(),
                                               SidechainETHWithdrawOperationCodingKeys.extensions.rawValue: extensions.toJSON(),
                                               SidechainETHWithdrawOperationCodingKeys.value.rawValue: value,
                                               SidechainETHWithdrawOperationCodingKeys.ethAddress.rawValue: ethAddress]
        
        array.append(dictionary)
        
        return array
    }
}
