//
//  SidechainDepositEnum.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 12.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Enum which contains sidechain deposit for different sidechain
 */
public enum SidechainDepositEnum: Decodable {
    case eth(EthDeposit)
    case btc(BtcDeposit)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let ethDeposit = try? container.decode(EthDeposit.self) {
            self = .eth(ethDeposit)
            return
        }
        
        if let btcDeposit = try? container.decode(BtcDeposit.self) {
            self = .btc(btcDeposit)
            return
        }
        
        throw ECHOError.encodableMapping
    }
}
