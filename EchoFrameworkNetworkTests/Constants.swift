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
    
    static let defaultName = "DEFAULT_NAME"
    static let defaultToName = "DEFAULT_TO_NAME"
    static let defaultWIF = "DEFAULT_WIF"
    
    static let defaultAsset = "DEFAULT_ASSET"
    static let defaultAssetLowerBound = "DEFAULT_ASSET_LOWER_BOUND"
    static let defaultAnotherAsset = "DEFAULT_ANOTHER_ASSET"
    
    static let defaultETHAddress = "DEFAULT_ETH_ADDRESS"
    static let defaultBTCAddress = "DEFAULT_BTC_ADDRESS"
    
    static let defaultLogsContractMethod = "DEFAULT_LOGS_CONTRACT_METHOD"
    static let defaultCallContractMethod = "DEFAULT_CALL_CONTRACT_METHOD"
    static let defaultCallContractBytecode = "DEFAULT_CALL_CONTRACT_BYTECODE"
    static let defaultQueryContractMethod = "DEFAULT_QUERY_CONTRACT_METHOD"
    static let defaultQueryContractBytecode = "DEFAULT_QUERY_CONTRACT_BYTECODE"
    
    static let evmContractResult = "EVM_CONTRACT_RESULT"
    static let x86ContractResult = "X86_CONTRACT_RESULT"
    
    static let contractLogsFromBlock = "CONTRACT_LOGS_FROM_BLOCK"
    
    static let logContractByteCode = "LOGS_CONTRACT_BYTECODE"
    static let counterContractByteCode = "COUNTER_CONTRACT_BYTECODE"
    
    static let defaultBlockNumber = "DEFAULT_BLOCK_NUMBER"
    static let defaultTransactionID = "DEFAULT_TRANSACTION_ID"
    
    static let erc20Token = "ERC20_TOKEN"
    static let erc20TokenEchoId = "ERC20_TOKEN_ECHO_ID"
    static let erc20TokenEchoContract = "ERC20_TOKEN_ECHO_CONTRACT"
    static let erc20TokenNotRegistered = "ERC20_TOKEN_NOT_REGISTERED"
    static let erc20TokenName = "ERC20_TOKEN_NAME"
    static let erc20TokenSymbol = "ERC20_TOKEN_SYMBOL"
    static let erc20TokenDecimals = "ERC20_TOKEN_DECIMALS"
}

struct Constants {
    static var nodeUrl: String {
        return "ws://" + Constants.infoForKey(ConstantsKeys.nodeUrlKey)! + "/ws"
    }
    
    static var timeout: Double {
        return Double(Constants.infoForKey(ConstantsKeys.timeout)!)!
    }
    
    static var counterContract: String {
        return Constants.infoForKey(ConstantsKeys.counterContract)!
    }
    
    static var logsContract: String {
        return Constants.infoForKey(ConstantsKeys.logsContract)!
    }
    
    static var x86Contract: String {
        return Constants.infoForKey(ConstantsKeys.x86Contract)!
    }
    
    static var defaultName: String {
        return Constants.infoForKey(ConstantsKeys.defaultName)!
    }
    
    static var defaultToName: String {
        return Constants.infoForKey(ConstantsKeys.defaultToName)!
    }
    
    static var defaultWIF: String {
        return Constants.infoForKey(ConstantsKeys.defaultWIF)!
    }
    
    static var defaultAsset: String {
        return Constants.infoForKey(ConstantsKeys.defaultAsset)!
    }
    
    static var defaultAssetLowerBound: String {
        return Constants.infoForKey(ConstantsKeys.defaultAssetLowerBound)!
    }
    
    static var defaultAnotherAsset: String {
        return Constants.infoForKey(ConstantsKeys.defaultAnotherAsset)!
    }
    
    static var defaultETHAddress: String {
        return Constants.infoForKey(ConstantsKeys.defaultETHAddress)!
    }
    
    static var defaultBTCAddress: String {
        return Constants.infoForKey(ConstantsKeys.defaultBTCAddress)!
    }
    
    static var defaultCallContractMethod: String {
        return Constants.infoForKey(ConstantsKeys.defaultCallContractMethod)!
    }
    
    static var defaultLogsContractMethod: String {
        return Constants.infoForKey(ConstantsKeys.defaultLogsContractMethod)!
    }
    
    static var defaultCallContractBytecode: String {
        return Constants.infoForKey(ConstantsKeys.defaultCallContractBytecode)!
    }
    
    static var defaultQueryContractMethod: String {
        return Constants.infoForKey(ConstantsKeys.defaultQueryContractMethod)!
    }
    
    static var defaultQueryContractBytecode: String {
        return Constants.infoForKey(ConstantsKeys.defaultQueryContractBytecode)!
    }
    
    static var evmContractResult: String {
        return Constants.infoForKey(ConstantsKeys.evmContractResult)!
    }
    
    static var x86ContractResult: String {
        return Constants.infoForKey(ConstantsKeys.x86ContractResult)!
    }
    
    static var contractLogsFromBlock: Int {
        return Int(Constants.infoForKey(ConstantsKeys.contractLogsFromBlock)!)!
    }
    
    static var logContractByteCode: String {
        return Constants.infoForKey(ConstantsKeys.logContractByteCode)!
    }
    
    static var counterContractByteCode: String {
        return Constants.infoForKey(ConstantsKeys.counterContractByteCode)!
    }
    
    static var defaultBlockNumber: Int {
        return Int(Constants.infoForKey(ConstantsKeys.defaultBlockNumber)!)!
    }
    
    static var defaultTransactionID: String {
        return Constants.infoForKey(ConstantsKeys.defaultTransactionID)!
    }
    
    static var erc20Token: String {
        return Constants.infoForKey(ConstantsKeys.erc20Token)!
    }
    
    static var erc20TokenEchoId: String {
        return Constants.infoForKey(ConstantsKeys.erc20TokenEchoId)!
    }
    
    static var erc20TokenEchoContract: String {
        return Constants.infoForKey(ConstantsKeys.erc20TokenEchoContract)!
    }
    
    static var erc20TokenNotRegistered: String {
        return Constants.infoForKey(ConstantsKeys.erc20TokenNotRegistered)!
    }
    
    static var erc20TokenName: String {
        return Constants.infoForKey(ConstantsKeys.erc20TokenName)!
    }
    
    static var erc20TokenSymbol: String {
        return Constants.infoForKey(ConstantsKeys.erc20TokenSymbol)!
    }
    
    static var erc20TokenDecimals: UInt8 {
        return UInt8(Constants.infoForKey(ConstantsKeys.erc20TokenDecimals)!)!
    }
    
    static func infoForKey(_ key: String) -> String? {
        
        let findedBundle = Bundle.allBundles.first { (bundle) -> Bool in
            return bundle.bundlePath.contains("EchoFrameworkNetworkTests.xctest")
        }
        
        guard let infoPlist = findedBundle?.infoDictionary else {
            return nil
        }
        
        return (infoPlist[key] as? String)?.replacingOccurrences(of: "\\", with: "")
    }
}
