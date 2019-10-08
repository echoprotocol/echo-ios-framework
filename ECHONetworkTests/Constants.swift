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
    static let defaultWIF = "DEFAULT_WIF"
    
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
    
    static let logContractByteCode = "LOGS_CONTRACT_BYTECODE"
    static let counterContractByteCode = "COUNTER_CONTRACT_BYTECODE"
    
    static let defaultBlockNumber = "DEFAULT_BLOCK_NUMBER"
}

struct Constants {
    
    static var nodeUrl: String {
        if let value = Constants.infoForKey(ConstantsKeys.nodeUrlKey) {
            return "wss://" + value
        } else {
            return "wss://testnet.echo-dev.io"
        }
    }
    
    static var timeout: Double {
        if let valueString = Constants.infoForKey(ConstantsKeys.timeout),
            let value = Double(valueString) {
            return value
        } else {
            return 20
        }
    }
    
    static var counterContract: String {
        if let value = Constants.infoForKey(ConstantsKeys.counterContract) {
            return value
        } else {
            return "1.9.498"
        }
    }
    
    static var logsContract: String {
        if let value = Constants.infoForKey(ConstantsKeys.logsContract) {
            return value
        } else {
            return "1.9.497"
        }
    }
    
    static var x86Contract: String {
        if let value = Constants.infoForKey(ConstantsKeys.x86Contract) {
            return value
        } else {
            return "1.9.0"
        }
    }
    
    static var sidechainTransferObject: String {
        if let value = Constants.infoForKey(ConstantsKeys.sidechainTransferObject) {
            return value
        } else {
            return "1.17.0"
        }
    }
    
    static var defaultName: String {
        if let value = Constants.infoForKey(ConstantsKeys.defaultName) {
            return value
        } else {
            return "vsharaev"
        }
    }
    
    static var defaultToName: String {
        if let value = Constants.infoForKey(ConstantsKeys.defaultToName) {
            return value
        } else {
            return "vsharaev1"
        }
    }
    
    static var defaultWIF: String {
        if let value = Constants.infoForKey(ConstantsKeys.defaultWIF) {
            return value
        } else {
            return "5KjC8BiryoxUNz3dEY2ZWQK5ssmD84JgRGemVWwxfNgiPoxcaVa"
        }
    }
    
    static var defaultAsset: String {
        if let value = Constants.infoForKey(ConstantsKeys.defaultAsset) {
            return value
        } else {
            return "1.3.0"
        }
    }
    
    static var defaultAssetLowerBound: String {
        if let value = Constants.infoForKey(ConstantsKeys.defaultAssetLowerBound) {
            return value
        } else {
            return "ECHO"
        }
    }
    
    static var defaultAnotherAsset: String {
        if let value = Constants.infoForKey(ConstantsKeys.defaultAnotherAsset) {
            return value
        } else {
            return "1.3.91"
        }
    }
    
    static var defaultETHAddress: String {
        if let value = Constants.infoForKey(ConstantsKeys.defaultETHAddress) {
            return value
        } else {
            return "0x46Ba2677a1c982B329A81f60Cf90fBA2E8CA9fA8"
        }
    }
    
    static var defaultCallContractMethod: String {
        if let value = Constants.infoForKey(ConstantsKeys.defaultCallContractMethod) {
            return value
        } else {
            return "incrementCounter"
        }
    }
    
    static var defaultLogsContractMethod: String {
        if let value = Constants.infoForKey(ConstantsKeys.defaultLogsContractMethod) {
            return value
        } else {
            return "test"
        }
    }
    
    static var defaultCallContractBytecode: String {
        if let value = Constants.infoForKey(ConstantsKeys.defaultCallContractBytecode) {
            return value
        } else {
            return "5b34b966"
        }
    }
    
    static var defaultQueryContractMethod: String {
        if let value = Constants.infoForKey(ConstantsKeys.defaultQueryContractMethod) {
            return value
        } else {
            return "getCount"
        }
    }
    
    static var defaultQueryContractBytecode: String {
        if let value = Constants.infoForKey(ConstantsKeys.defaultQueryContractBytecode) {
            return value
        } else {
            return "a87d942c"
        }
    }
    
    static var evmContractResult: String {
        if let value = Constants.infoForKey(ConstantsKeys.evmContractResult) {
            return value
        } else {
            return "1.10.988"
        }
    }
    
    static var x86ContractResult: String {
        if let value = Constants.infoForKey(ConstantsKeys.x86ContractResult) {
            return value
        } else {
            return "1.10.0"
        }
    }
    
    static var contractLogsFromBlock: Int {
        if let valueString = Constants.infoForKey(ConstantsKeys.contractLogsFromBlock),
            let value = Int(valueString) {
            return value
        } else {
            return 1247880
        }
    }
    
    static var logContractByteCode: String {
        if let value = Constants.infoForKey(ConstantsKeys.logContractByteCode) {
            return value
        } else {
            return "6080604052348015600f57600080fd5b5061010b8061001f6000396000f300608060405260043610603f576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff16806329e99f07146044575b600080fd5b348015604f57600080fd5b50606c60048036038101908080359060200190929190505050606e565b005b7fa7659801d76e732d0b4c81221c99e5cf387816232f81f4ff646ba0653d65507a436040518082815260200191505060405180910390a17fa7659801d76e732d0b4c81221c99e5cf387816232f81f4ff646ba0653d65507a816040518082815260200191505060405180910390a1505600a165627a7a723058202ee0ce6afeec3577644075456c235804fa783dcdbb61a981edaf50333f5ef6710029"
        }
    }
    
    static var counterContractByteCode: String {
        if let value = Constants.infoForKey(ConstantsKeys.counterContractByteCode) {
            return value
        } else {
            return "60806040526000805534801561001457600080fd5b50610101806100246000396000f3006080604052600436106053576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680635b34b966146058578063a87d942c14606c578063f5c5ad83146094575b600080fd5b348015606357600080fd5b50606a60a8565b005b348015607757600080fd5b50607e60ba565b6040518082815260200191505060405180910390f35b348015609f57600080fd5b5060a660c3565b005b60016000808282540192505081905550565b60008054905090565b600160008082825403925050819055505600a165627a7a7230582063e27ea8b308defeeb50719f281e50a9b53ffa155e56f3249856ef7eafeb09e90029"
        }
    }
    
    static var defaultBlockNumber: Int {
        if let valueString = Constants.infoForKey(ConstantsKeys.defaultBlockNumber),
            let value = Int(valueString) {
            return value
        } else {
            return 10
        }
    }
    
    static func infoForKey(_ key: String) -> String? {
        
        let findedBundle = Bundle.allBundles.first { (bundle) -> Bool in
            return bundle.bundlePath.contains("ECHONetworkTests.xctest")
        }
        
        guard let infoPlist = findedBundle?.infoDictionary else {
            return nil
        }
        
        return (infoPlist[key] as? String)?.replacingOccurrences(of: "\\", with: "")
    }
}
