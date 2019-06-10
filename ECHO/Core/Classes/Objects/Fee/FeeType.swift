//
//  FeeType.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 10/06/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

/**
    Represent fee type. Because different operations have different fee object
 */
public enum FeeType {
    case defaultFee(AssetAmount)
    case callContractFee(CallContractFee)
}
