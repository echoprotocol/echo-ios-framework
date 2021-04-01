//
//  SidechainERC20WithdrawTokenOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 29.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the
    [OperationType.sidechainERC20WithdrawTokenOperation](OperationType.sidechainERC20WithdrawTokenOperation)
 */
public struct SidechainERC20WithdrawTokenOperation: BaseOperation {
    
    enum SidechainERC20WithdrawTokenOperationCodingKeys: String, CodingKey {
        case account
        case toEthAddress = "to"
        case token = "erc20_token"
        case value
        case extensions
        case fee
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var account: Account
    public let toEthAddress: String
    public var token: ERC20Token
    public let value: String
    
    init(account: Account, toEthAddress: String, token: ERC20Token,
         value: String, fee: AssetAmount) {
        
        type = .sidechainERC20WithdrawTokenOperation

        self.fee = fee
        self.account = account
        self.toEthAddress = toEthAddress
        self.token = token
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        
        type = .sidechainERC20WithdrawTokenOperation
        
        let values = try decoder.container(keyedBy: SidechainERC20WithdrawTokenOperationCodingKeys.self)
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        fee = try values.decode(AssetAmount.self, forKey: .fee)

        let tokenId = try values.decode(String.self, forKey: .token)
        token = ERC20Token(id: tokenId)
        
        toEthAddress = try values.decode(String.self, forKey: .toEthAddress)
        value = try values.decode(String.self, forKey: .value)
    }
    
    mutating func changeToken(token: ERC20Token?) {
        
        if let token = token { self.token = token }
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
        
        let toData = Data(hex: toEthAddress)
        data.append(optional: Data.fromUIntLikeUnsignedByteArray(UInt(toData?.count ?? 0)))
        data.append(optional: toData)
        
        data.append(optional: token.toData())
        data.append(optional: Data.fromString(value))
        
        data.append(optional: extensions.toData())
        return data
    }
    
    public func toJSON() -> Any? {
        
        var array = [Any]()
        array.append(getId())
        
        let dictionary: [AnyHashable: Any?] = [SidechainERC20WithdrawTokenOperationCodingKeys.fee.rawValue: fee.toJSON(),
                                               SidechainERC20WithdrawTokenOperationCodingKeys.account.rawValue: account.toJSON(),
                                               SidechainERC20WithdrawTokenOperationCodingKeys.extensions.rawValue: extensions.toJSON(),
                                               SidechainERC20WithdrawTokenOperationCodingKeys.toEthAddress.rawValue: toEthAddress,
                                               SidechainERC20WithdrawTokenOperationCodingKeys.token.rawValue: token.toJSON(),
                                               SidechainERC20WithdrawTokenOperationCodingKeys.value.rawValue: value]
        
        array.append(dictionary)
        
        return array
    }
}
