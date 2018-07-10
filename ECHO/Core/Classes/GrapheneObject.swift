//
//  GrapheneObject.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 09.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

class GrapheneObject {
    
    var idString = ""
    var space: Int = 0
    var type: Int = 0
    var instance: Int = 0
    
    let keyID = "id"
    let protocolSpace: Int = 1
    let implementationSpace: Int = 2
    
    init(string idString: String) {
        
        self.idString = idString
        let parts = idString.components(separatedBy: ".")
        if parts.count == 3 {
            space = Int(parts[0]) ?? 0
            type = Int(parts[1]) ?? 0
            instance = Int(parts[2]) ?? 0
        }
    }
    
    func getId() -> String? {
        return "\(space).\(type).\(instance)"
    }
    
    func getType() -> ObjectType? {
        switch space {
        case protocolSpace:
            return getProtocolType(type: type)
        case implementationSpace:
            return getImplementationType(type: type)
        default:
            return nil
        }
    }
    
    fileprivate func getProtocolType(type: Int) -> ObjectType? {
        
        switch type {
        case 1:
            return .base
        case 2:
            return .account
        case 3:
            return .asset
        case 4:
            return .forceSettlement
        case 5:
            return .committeeMember
        case 6:
            return .witness
        case 7:
            return .limitOrder
        case 8:
            return .callOrder
        case 9:
            return .custom
        case 10:
            return .proposal
        case 11:
            return .operationHistory
        case 12:
            return .withdrawPermission
        case 13:
            return .vestingBalance
        case 14:
            return .worker
        case 15:
            return .balance
        case 16:
            return .contract
        default:
            return nil
        }
    }
    
    fileprivate func getImplementationType(type: Int) -> ObjectType? {
        
        switch type {
        case 0:
            return .globalProperty
        case 1:
            return .dynamicGlobalProperty
        case 3:
            return .assetDynamicData
        case 4:
            return .assetBitassetData
        case 5:
            return .accountBalance
        case 6:
            return .accountStatistics
        case 7:
            return .transaction
        case 8:
            return .blockSummary
        case 9:
            return .accountTransactionHistory
        case 10:
            return .blindedBalance
        case 11:
            return .chainProperty
        case 12:
            return .witnessSchedule
        case 13:
            return .budgetRecord
        case 14:
            return .specialAuthority
        default:
            return nil
        }
    }
}
