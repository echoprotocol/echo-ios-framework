//
//  SidechainBTCCreateIntermediateDepositOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 03.12.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Struct used to encapsulate operations related to the
    [OperationType.sidechainBTCCreateIntermediateDepositOperation](OperationType.sidechainBTCCreateIntermediateDepositOperation)
 */
public struct SidechainBTCCreateIntermediateDepositOperation: BaseOperation {
    
    enum SidechainBTCCreateIntermediateDepositOperationCodingKeys: String, CodingKey {
        case committeeMember = "committee_member_id"
        case account = "account"
        case btcAddressId = "btc_address_id"
        case txInfo = "tx_info"
        case extensions
        case fee
    }
    
    public let type: OperationType
    public let extensions: Extensions = Extensions()
    public var fee: AssetAmount
    
    public var committeeMember: Account
    public var account: Account
    public let btcAddressId: String
    public let txInfo: BtcDepositTransactionInfo
    
    public init(from decoder: Decoder) throws {
        
        type = .sidechainBTCCreateIntermediateDepositOperation
        
        let values = try decoder.container(keyedBy: SidechainBTCCreateIntermediateDepositOperationCodingKeys.self)
        
        let committeeMemberId = try values.decode(String.self, forKey: .committeeMember)
        committeeMember = Account(committeeMemberId)
        
        let accountId = try values.decode(String.self, forKey: .account)
        account = Account(accountId)
        
        btcAddressId = try values.decode(String.self, forKey: .btcAddressId)
        txInfo = try values.decode(BtcDepositTransactionInfo.self, forKey: .txInfo)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
    }
    
    mutating func changeAccounts(committeeMember: Account?, account: Account?) {
        
        if let account = account { self.account = account }
        if let committeeMember = committeeMember { self.committeeMember = committeeMember }
    }
    
    mutating func changeAssets(feeAsset: Asset?) {
        
        if let feeAsset = feeAsset { self.fee = AssetAmount(amount: fee.amount, asset: feeAsset) }
    }
    
    // MARK: ECHOCodable
    // Not called by user
    
    public func toData() -> Data? {
        
        return nil
    }
    
    public func toJSON() -> Any? {
        
        return nil
    }
}

