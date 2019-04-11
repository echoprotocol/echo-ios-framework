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
    
    static let timeout = " TIMEOUT"
    
    static let counterContract = "COUNTER_CONTRACT"
    static let logsContract = "LOGS_CONTRACT"
    
    static let defaultName = "DEFAULT_NAME"
    static let defaultPass = "DEFAULT_PASS"
    
    static let defaultAsset = "DEFAULT_ASSET"
    static let defaultAnotherAsset = "DEFAULT_ANOTHER_ASSET"
    
    static let defaultETHAddress = "DEFAULT_ETH_ADDRESS"
}

struct Constants {
    
    static let nodeUrl: String {
        if let value = Constants.infoForKey(ConstantsKeys.nodeUrlKey) {
            return value
        } else {
            return "wss://testnet.echo-dev.io"
        }
    }
    
    static let timeout: Double {
        if let valueString = Constants.infoForKey(ConstantsKeys.timeout),
            let value = Double(valueString) {
            return value
        } else {
            return 20
        }
    }
    
    static let counterContract: String {
        if let value = Constants.infoForKey(ConstantsKeys.counterContract) {
            return value
        } else {
            return "1.16.139"
        }
    }
    
    static let logsContract: String {
        if let value = Constants.infoForKey(ConstantsKeys.logsContract) {
            return value
        } else {
            return "1.16.141"
        }
    }
    
    static let defaultName: String {
        if let value = Constants.infoForKey(ConstantsKeys.defaultName) {
            return value
        } else {
            return "vsharaev"
        }
    }
    
    static let defaultPass: String {
        if let value = Constants.infoForKey(ConstantsKeys.defaultPass) {
            return value
        } else {
            return "vsharaev"
        }
    }
    
    static let defaultAsset: String {
        if let value = Constants.infoForKey(ConstantsKeys.defaultAsset) {
            return value
        } else {
            return "1.3.0"
        }
    }
    static let defaultAnotherAsset: String {
        if let value = Constants.infoForKey(ConstantsKeys.defaultAnotherAsset) {
            return value
        } else {
            return "1.3.20"
        }
    }
    
    static let defaultETHAddress: String {
        if let value = Constants.infoForKey(ConstantsKeys.defaultETHAddress) {
            return value
        } else {
            return "0x46Ba2677a1c982B329A81f60Cf90fBA2E8CA9fA8"
        }
    }
    
    static func infoForKey(_ key: String) -> String? {
        return (Bundle.main.infoDictionary?[key] as? String)?.replacingOccurrences(of: "\\", with: "")
    }
}
