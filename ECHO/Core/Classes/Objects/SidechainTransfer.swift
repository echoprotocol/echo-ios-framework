//
//  SidechainTransfer.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 11/03/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

public struct SidechainTransfer: Decodable {
    
    private enum SidechainTransferCodingKeys: String, CodingKey {
        case identifier = "id"
        case transferId = "transfer_id"
        case receiver
        case amount
        case signatures
        case withdrawCode = "withdraw_code"
    }
    
    var identifier: String
    let transferId: UInt
    let receiver: String
    let amount: IntOrString
    let signatures: String
    let withdrawCode: String
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: SidechainTransferCodingKeys.self)
        
        identifier = try values.decode(String.self, forKey: .identifier)
        transferId = try values.decode(UInt.self, forKey: .transferId)
        receiver = try values.decode(String.self, forKey: .receiver)
        amount = try values.decode(IntOrString.self, forKey: .amount)
        signatures = try values.decode(String.self, forKey: .signatures)
        withdrawCode = try values.decode(String.self, forKey: .withdrawCode)
    }
}
