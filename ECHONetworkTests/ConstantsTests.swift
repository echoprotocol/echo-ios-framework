//
//  ConstantsTests.swift
//  ECHONetworkTests
//
//  Created by Vladimir Sharaev on 18/04/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation
import XCTest

class ConstantsTests: XCTestCase {

    func testLoadConstants() {
        
        let nodeUrl = Constants.nodeUrl
        let timeout = Constants.timeout
        let counterContract = Constants.counterContract
        let logsContract = Constants.logsContract
        let x86Contract = Constants.x86Contract
        let sidechainTransferObject = Constants.sidechainTransferObject
        let defaultName = Constants.defaultName
        let defaultToName = Constants.defaultToName
        let defaultPass = Constants.defaultPass
        let defaultAsset = Constants.defaultAsset
        let defaultAssetLowerBound = Constants.defaultAssetLowerBound
        let defaultAnotherAsset = Constants.defaultAnotherAsset
        let defaultETHAddress = Constants.defaultETHAddress
        let defaultCallContractMethod = Constants.defaultCallContractMethod
        let defaultCallContractBytecode = Constants.defaultCallContractBytecode
        let defaultQueryContractMethod = Constants.defaultQueryContractMethod
        let defaultQueryContractBytecode = Constants.defaultQueryContractBytecode
        let evmContractResult = Constants.evmContractResult
        let x86ContractResult = Constants.x86ContractResult
        let contractLogsFromBlock = Constants.contractLogsFromBlock
        let contractLogsToBlock = Constants.contractLogsToBlock
        let logContractByteCode = Constants.logContractByteCode
        let counterContractByteCode = Constants.counterContractByteCode

        
        print(nodeUrl)
        print(timeout)
        print(counterContract)
        print(logsContract)
        print(x86Contract)
        print(sidechainTransferObject)
        print(defaultName)
        print(defaultToName)
        print(defaultPass)
        print(defaultAsset)
        print(defaultAssetLowerBound)
        print(defaultAnotherAsset)
        print(defaultETHAddress)
        print(defaultCallContractMethod)
        print(defaultCallContractBytecode)
        print(defaultQueryContractMethod)
        print(defaultQueryContractBytecode)
        print(evmContractResult)
        print(x86ContractResult)
        print(contractLogsFromBlock)
        print(contractLogsToBlock)
        print(logContractByteCode)
        print(counterContractByteCode)
        
        XCTAssertTrue(true)
    }
}
