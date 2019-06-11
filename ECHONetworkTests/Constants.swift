//
//  Constants.swift
//  ECHONetworkTests
//
//  Created by Vladimir Sharaev on 01/04/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

struct ConstantsKeys {
    
    static let nodeUrlKey = "NODE_URL"
    
    static let timeout = "TIMEOUT"
    
    static let counterContract = "COUNTER_CONTRACT"
    static let logsContract = "LOGS_CONTRACT"
    static let x86Contract = "X86_CONTRACT"
    static let sidechainTransferObject = "SIDECHAIN_TRANSFER_OBJECT"
    
    static let defaultName = "DEFAULT_NAME"
    static let defaultToName = "DEFAULT_TO_NAME"
    static let defaultPass = "DEFAULT_PASS"
    
    static let defaultAsset = "DEFAULT_ASSET"
    static let defaultAssetLowerBound = "DEFAULT_ASSET_LOWER_BOUND"
    static let defaultAnotherAsset = "DEFAULT_ANOTHER_ASSET"
    
    static let defaultETHAddress = "DEFAULT_ETH_ADDRESS"
    
    static let defaultLogsContractMethod = "DEFAULT_LOGS_CONTRACT_METHOD"
    static let defaultCallContractMethod = "DEFAULT_CALL_CONTRACT_METHOD"
    static let defaultCallContractBytecode = "DEFAULT_CALL_CONTRACT_BYTECODE"
    static let defaultQueryContractMethod = "DEFAULT_QUERY_CONTRACT_METHOD"
    static let defaultQueryContractBytecode = "DEFAULT_QUERY_CONTRACT_BYTECODE"
    
    static let evmContractResult = "EVM_CONTRACT_RESULT"
    static let x86ContractResult = "X86_CONTRACT_RESULT"
    
    static let contractLogsFromBlock = "CONTRACT_LOGS_FROM_BLOCK"
    static let contractLogsToBlock = "CONTRACT_LOGS_TO_BLOCK"
    
    static let logContractByteCode = "LOGS_CONTRACT_BYTECODE"
    static let counterContractByteCode = "COUNTER_CONTRACT_BYTECODE"
    
    static let defaultBlockNumber = "DEFAULT_BLOCK_NUMBER"
}

struct Constants {
    
    static var nodeUrl: String {
        let value = Constants.infoForKey(ConstantsKeys.nodeUrlKey)
        return "wss://" + value
    }
    
    static var timeout: Double {
        let valueString = Constants.infoForKey(ConstantsKeys.timeout)
        let value = Double(valueString) ?? 20
        return value
    }
    
    static var counterContract: String {
        let value = Constants.infoForKey(ConstantsKeys.counterContract)
        return value
    }
    
    static var logsContract: String {
        let value = Constants.infoForKey(ConstantsKeys.logsContract)
        return value
    }
    
    static var x86Contract: String {
        let value = Constants.infoForKey(ConstantsKeys.x86Contract)
        return value
    }
    
    static var sidechainTransferObject: String {
        let value = Constants.infoForKey(ConstantsKeys.sidechainTransferObject)
        return value
    }
    
    static var defaultName: String {
        let value = Constants.infoForKey(ConstantsKeys.defaultName)
        return value
    }
    
    static var defaultToName: String {
        let value = Constants.infoForKey(ConstantsKeys.defaultToName)
        return value
    }
    
    static var defaultPass: String {
        let value = Constants.infoForKey(ConstantsKeys.defaultPass)
        return value
    }
    
    static var defaultAsset: String {
        let value = Constants.infoForKey(ConstantsKeys.defaultAsset)
        return value
    }
    
    static var defaultAssetLowerBound: String {
        let value = Constants.infoForKey(ConstantsKeys.defaultAssetLowerBound)
        return value
    }
    
    static var defaultAnotherAsset: String {
        let value = Constants.infoForKey(ConstantsKeys.defaultAnotherAsset)
        return value
    }
    
    static var defaultETHAddress: String {
        let value = Constants.infoForKey(ConstantsKeys.defaultETHAddress)
        return value
    }
    
    static var defaultCallContractMethod: String {
        let value = Constants.infoForKey(ConstantsKeys.defaultCallContractMethod)
        return value
    }
    
    static var defaultLogsContractMethod: String {
        let value = Constants.infoForKey(ConstantsKeys.defaultLogsContractMethod)
        return value
    }
    
    static var defaultCallContractBytecode: String {
        let value = Constants.infoForKey(ConstantsKeys.defaultCallContractBytecode)
        return value
    }
    
    static var defaultQueryContractMethod: String {
        let value = Constants.infoForKey(ConstantsKeys.defaultQueryContractMethod)
        return value
    }
    
    static var defaultQueryContractBytecode: String {
        let value = Constants.infoForKey(ConstantsKeys.defaultQueryContractBytecode)
        return value
    }
    
    static var evmContractResult: String {
        let value = Constants.infoForKey(ConstantsKeys.evmContractResult)
        return value
    }
    
    static var x86ContractResult: String {
        let value = Constants.infoForKey(ConstantsKeys.x86ContractResult)
        return value
    }
    
    static var contractLogsFromBlock: Int {
        let valueString = Constants.infoForKey(ConstantsKeys.contractLogsFromBlock)
        let value = Int(valueString) ?? 0
        return value
    }
    
    static var contractLogsToBlock: Int {
        let valueString = Constants.infoForKey(ConstantsKeys.contractLogsToBlock)
        let value = Int(valueString) ?? 0
        return value
    }
    
    static var logContractByteCode: String {
        let value = Constants.infoForKey(ConstantsKeys.logContractByteCode)
        return value
    }
    
    static var counterContractByteCode: String {
        let value = Constants.infoForKey(ConstantsKeys.counterContractByteCode)
        return value
    }
    
    static var defaultBlockNumber: Int {
        let valueString = Constants.infoForKey(ConstantsKeys.defaultBlockNumber)
        let value = Int(valueString) ?? 0
        return value
    }
    
    static func infoForKey(_ key: String) -> String {
        
        let findedBundle = Bundle.allBundles.first { (bundle) -> Bool in
            return bundle.bundlePath.contains("ECHONetworkTests.xctest")
        }
        
        let infoPlist = findedBundle!.infoDictionary!
        let anyValue = infoPlist[key]!
        let stringValue = anyValue as! String
        
        return stringValue.replacingOccurrences(of: "\\", with: "")
    }
}
