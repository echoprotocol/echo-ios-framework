//
//  CallContractFee.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 10/06/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

public struct CallContractFee: Decodable {
    
    enum CallContractFeeCodingKeys: String, CodingKey {
        case fee
        case userToPay = "user_to_pay"
    }
    
    public let fee: AssetAmount
    public let userToPay: AssetAmount
    
    public init(fee: AssetAmount, userToPay: AssetAmount) {
        
        self.fee = fee
        self.userToPay = userToPay
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CallContractFeeCodingKeys.self)
        fee = try values.decode(AssetAmount.self, forKey: .fee)
        userToPay = try values.decode(AssetAmount.self, forKey: .userToPay)
    }
}
