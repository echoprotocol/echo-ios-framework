//
//  ObjectType.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 21.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Enum type used to list all possible spaces in Graphene blockchain
 */
public enum ObjectSpace: Int {
    case protocolSpace = 1
    case implementationSpace
    case undefined
}

/**
    Enum type used to list all possible object types in Graphene blockchain
    Every element contains information about it's type and space
 */
public enum ObjectType: Int {
    case null = 0
    case base
    case account
    case asset
    case committeeMember
    case proposal
    case operationHistory
    case vestingBalance
    case balance
    case frozenBalance
    case committeeFrozenBalance     //10
    case contract
    case contractResult
    case ethAddress
    case depositEth
    case withdrawEth
    case erc20Token
    case depositERC20Token
    case withdrawERC20Token
    case btcAddress
    case btcIntermediateDeposit     //20
    case btcDeposit
    case btcWithdraw
    case btcAggregating
    case globalProperty
    case dynamicGlobalProperty
    case assetDynamicData
    case assetBitassetData
    case accountBalance
    case accountStatistics
    case transaction
    case blockSummary
    case accountTransactionHistory
    case chainProperty
    case specialAuthority
    case contractBalance
    case contractHistory
    case contractStatistics
    case accountAddress
    case contractPool
    case maliciousCommitteemen
    case undefined
    
    func getGenericObjectId() -> String? {
        return "\(getSpace().rawValue).\(rawValue).0"
    }
    
    func getFullObjectIdByLastPart(_ lastPart: String) -> String {
        return "\(getSpace().rawValue).\(rawValue).\(lastPart)"
    }
    
    func getSpace() -> ObjectSpace {
        return ObjectType.getSpace(type: self)
    }
    
    static func getSpace(type: ObjectType) -> ObjectSpace {
        var space: ObjectSpace
        switch type {
        case .null,
             .base,
             .account,
             .asset,
             .committeeMember,
             .proposal,
             .operationHistory,
             .vestingBalance,
             .balance,
             .frozenBalance,
             .committeeFrozenBalance,
             .contract,
             .contractResult,
             .ethAddress,
             .depositEth,
             .withdrawEth,
             .erc20Token,
             .depositERC20Token,
             .withdrawERC20Token,
             .btcAddress,
             .btcIntermediateDeposit,
             .btcDeposit,
             .btcWithdraw,
             .btcAggregating:
            space = .protocolSpace
        case .globalProperty,
             .dynamicGlobalProperty,
             .assetDynamicData,
             .assetBitassetData,
             .accountBalance,
             .accountStatistics,
             .transaction,
             .blockSummary,
             .accountTransactionHistory,
             .chainProperty,
             .specialAuthority,
             .contractBalance,
             .contractHistory,
             .contractStatistics,
             .accountAddress,
             .contractPool,
             .maliciousCommitteemen:
            space = .implementationSpace
        case .undefined:
            space = .undefined
        }
        return space
    }
}

/**
    Struct used to validate object identifier by [ObjectType](ObjectType)
 */
struct IdentifierValidator {
    
    func validateId(_ identifier: String, for type: ObjectType) throws {
        
        let space = ObjectType.getSpace(type: type)
        let identifierSpaceInt = try getIdSubIntAt(identifier: identifier, index: 0)
        
        guard let identifierSpace = ObjectSpace(rawValue: identifierSpaceInt) else {
            throw ECHOError.identifier(type)
        }
        
        if identifierSpace != space {
            throw ECHOError.identifier(type)
        }
        
        let indetifierTypeInt = try getIdSubIntAt(identifier: identifier, index: 1)
        guard let identifierType = ObjectType(rawValue: indetifierTypeInt) else {
            throw ECHOError.identifier(type)
        }
        
        if identifierType != type {
            throw ECHOError.identifier(type)
        }
    }
    
    fileprivate func getIdSubIntAt(identifier: String, index: Int) throws -> Int {
        
        let values = identifier.components(separatedBy: ".")
        
        guard let string = values[safe: index], let intValue = Int(string)else {
            throw ECHOError.identifierFormat
        }
        
        return intValue
    }
}
