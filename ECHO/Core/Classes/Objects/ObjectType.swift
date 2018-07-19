//
//  ObjectType.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 09.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

enum ObjectType: Int {
    case base = 1
    case account
    case asset
    case forceSettlement
    case committeeMember
    case witness
    case limitOrder
    case callOrder
    case custom
    case proposal
    case operationHistory
    //10
    case withdrawPermission
    case vestingBalance
    case worker
    case balance
    case globalProperty
    case dynamicGlobalProperty
    case assetDynamicData
    case assetBitassetData
    case accountBalance
    case accountStatistics
    //20
    case transaction
    case blockSummary
    case accountTransactionHistory
    case blindedBalance
    case chainProperty
    case witnessSchedule
    case budgetRecord
    case specialAuthority
    case contract
    
    func getGenericObjectId() -> String? {
        return "\(getSpace()).\(rawValue).0"
    }
    
    func getSpace() -> Int {
        var space: Int
        switch self {
        case .base,
             .account,
             .asset,
             .forceSettlement,
             .committeeMember,
             .witness, .limitOrder,
             .callOrder,
             .custom,
             .proposal,
             .operationHistory,
             .withdrawPermission,
             .vestingBalance,
             .worker, .balance:
            space = 1
        case .globalProperty,
             .dynamicGlobalProperty,
             .assetDynamicData,
             .assetBitassetData,
             .accountBalance,
             .accountStatistics,
             .transaction,
             .blockSummary,
             .accountTransactionHistory,
             .blindedBalance,
             .chainProperty,
             .witnessSchedule,
             .budgetRecord,
             .specialAuthority:
            space = 2
        default:
            space = 1
        }
        return space
    }
}
