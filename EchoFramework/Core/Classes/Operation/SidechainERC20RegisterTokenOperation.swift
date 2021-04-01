//
//  SidechainERC20RegisterTokenOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 29.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the
    [OperationType.sidechainERC20RegisterTokenOperation](OperationType.sidechainERC20RegisterTokenOperation)
 */
public struct SidechainERC20RegisterTokenOperation: BaseOperation {
    
    enum SidechainERC20RegisterTokenOperationCodingKeys: String, CodingKey {
        case account
        case ethAddress = "eth_addr"
        case name
        case symbol
        case decimals
        case extensions
        case fee
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var account: Account
    public let ethAddress: String
    public let name: String
    public let symbol: String
    public let decimals: UInt8
    
    init(account: Account, ethAddress: String, name: String,
         symbol: String, decimals: UInt8, fee: AssetAmount) {
        
        type = .sidechainERC20RegisterTokenOperation

        self.fee = fee
        self.account = account
        self.ethAddress = ethAddress
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .sidechainERC20RegisterTokenOperation
        
        let values = try decoder.container(keyedBy: SidechainERC20RegisterTokenOperationCodingKeys.self)
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
        
        ethAddress = try values.decode(String.self, forKey: .ethAddress)
        name = try values.decode(String.self, forKey: .name)
        symbol = try values.decode(String.self, forKey: .symbol)
        decimals = try values.decode(UInt8.self, forKey: .decimals)
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
        
        data.append(optional: Data.fromString(name))
        data.append(optional: Data.fromString(symbol))
        data.append(optional: Data.fromUInt8(decimals))
        
        data.append(optional: extensions.toData())
        return data
    }
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        let dictionary: [AnyHashable: Any?] = [SidechainERC20RegisterTokenOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               SidechainERC20RegisterTokenOperationCodingKeys.account.rawValue: account.toJSON(),
                                               SidechainERC20RegisterTokenOperationCodingKeys.extensions.rawValue: extensions.toJSON(),
                                               SidechainERC20RegisterTokenOperationCodingKeys.ethAddress.rawValue: ethAddress,
                                               SidechainERC20RegisterTokenOperationCodingKeys.name.rawValue: name,
                                               SidechainERC20RegisterTokenOperationCodingKeys.symbol.rawValue: symbol,
                                               SidechainERC20RegisterTokenOperationCodingKeys.decimals.rawValue: decimals]
        
        array.append(dictionary)
        
        return array
    }
}
