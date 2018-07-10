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
    
    // swiftlint:disable function_body_length
    func getType() -> ObjectType? {
        switch space {
        case protocolSpace:
            switch type {
            case 1:
                return ObjectType.withType(.base)
            case 2:
                return ObjectType.withType(.account)
            case 3:
                return ObjectType.withType(.asset)
            case 4:
                return ObjectType.withType(.forceSettlement)
            case 5:
                return ObjectType.withType(.committeeMember)
            case 6:
                return ObjectType.withType(.witness)
            case 7:
                return ObjectType.withType(.limitOrder)
            case 8:
                return ObjectType.withType(.callOrder)
            case 9:
                return ObjectType.withType(.custom)
            case 10:
                return ObjectType.withType(.proposal)
            case 11:
                return ObjectType.withType(.operationHistory)
            case 12:
                return ObjectType.withType(.withdrawPermission)
            case 13:
                return ObjectType.withType(.vestingBalance)
            case 14:
                return ObjectType.withType(.worker)
            case 15:
                return ObjectType.withType(.balance)
            case 16:
                return ObjectType.withType(.contract)
            default:
                break
            }
        case implementationSpace:
            switch type {
            case 0:
                return ObjectType.withType(.globalProperty)
            case 1:
                return ObjectType.withType(.dynamicGlobalProperty)
            case 3:
                return ObjectType.withType(.assetDynamicData)
            case 4:
                return ObjectType.withType(.assetBitassetData)
            case 5:
                return ObjectType.withType(.accountBalance)
            case 6:
                return ObjectType.withType(.accountStatistics)
            case 7:
                return ObjectType.withType(.transaction)
            case 8:
                return ObjectType.withType(.blockSummary)
            case 9:
                return ObjectType.withType(.accountTransactionHistory)
            case 10:
                return ObjectType.withType(.blindedBalance)
            case 11:
                return ObjectType.withType(.chainProperty)
            case 12:
                return ObjectType.withType(.witnessSchedule)
            case 13:
                return ObjectType.withType(.budgetRecord)
            case 14:
                return ObjectType.withType(.specialAuthority)
            default:
                break
            }
        default:
            break
        }
        return nil
    }
    // swiftlint:enable function_body_length
}
