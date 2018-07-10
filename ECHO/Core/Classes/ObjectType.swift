//
//  ObjectType.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 09.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

enum ObjectTypes: Int {
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
}

class ObjectType {
    
    var type: ObjectTypes!
    
    class func withType(_ type: ObjectTypes) -> ObjectType? {
        let newType = ObjectType()
        newType.type = type
        return newType
    }
    
    func getSpace() -> Int {
        var space: Int
        switch type {
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
    
    func getType() -> Int {
        return type.rawValue
    }
    func getGenericObjectId() -> String? {
        return "\(getSpace()).\(getType()).0"
    }
}
