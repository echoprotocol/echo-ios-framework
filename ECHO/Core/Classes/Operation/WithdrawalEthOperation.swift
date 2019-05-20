//
//  WithdrawalEthOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 20/05/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the [OperationType.withdrawEthOperation](OperationType.withdrawEthOperation)
 */
public struct WithdrawalEthOperation: BaseOperation {
    
    enum WithdrawalEthOperationCodingKeys: String, CodingKey {
        case account = "acc_id"
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
        
        type = .withdrawEthOperation
        
        self.account = account
        self.fee = fee
        self.value = value
        self.ethAddress = ethAddress
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .withdrawEthOperation
        
        let values = try decoder.container(keyedBy: WithdrawalEthOperationCodingKeys.self)
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        ethAddress = try values.decode(String.self, forKey: .ethAddress)
        value = try values.decode(UInt.self, forKey: .value)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
    }
    
    mutating func changeAccount(account: Account?) {
        
        if let account = account { self.account = account }
    }
    
    // MARK: ECHOCodable
    
    public func toData() -> Data? {
        
        var data = Data()
//        data.append(optional: fee.toData())
        data.append(optional: account.toData())
        
        data.append(optional: Data.fromUIntLikeUnsignedByteArray(UInt(ethAddress.count)))
        data.append(optional: ethAddress.data(using: .utf8))
        
        data.append(optional: Data.fromUint64(value))
        data.append(optional: extensions.toData())
        return data
    }
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        let dictionary: [AnyHashable: Any?] = [WithdrawalEthOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               WithdrawalEthOperationCodingKeys.account.rawValue: account.toJSON(),
                                               WithdrawalEthOperationCodingKeys.extensions.rawValue: extensions.toJSON(),
                                               WithdrawalEthOperationCodingKeys.value.rawValue: value,
                                               WithdrawalEthOperationCodingKeys.ethAddress.rawValue: ethAddress]
        
        array.append(dictionary)
        
        return array
    }
}
