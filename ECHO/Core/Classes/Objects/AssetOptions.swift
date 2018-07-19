//
//  AssetOptions.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct AssetOptions {
    
    var maxSupply: UInt
    var marketFeePercent: Double
    var maxMarketFee: UInt
    var issuerPermissions: Int
    var flags: Int
    var coreExchangeRate: Price?
}
