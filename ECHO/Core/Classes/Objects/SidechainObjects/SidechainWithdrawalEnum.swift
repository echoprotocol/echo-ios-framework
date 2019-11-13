//
//  SidechainWithdrawalEnum.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 12.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Enum which contains sidechain withdrawal for different sidechain
 */
public enum SidechainWithdrawalEnum: Decodable {
    case eth(EthWithdrawal)
    case btc(BtcWithdrawal)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let ethWithdrawal = try? container.decode(EthWithdrawal.self) {
            self = .eth(ethWithdrawal)
            return
        }
        
        if let btcWithdrawal = try? container.decode(BtcWithdrawal.self) {
            self = .btc(btcWithdrawal)
            return
        }
        
        throw ECHOError.encodableMapping
    }
}
