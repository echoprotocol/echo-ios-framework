//
//  ContractLogsSubscribeTests.swift
//  ECHONetworkTests
//
//  Created by Vladimir Sharaev on 11.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import XCTest
@testable import EchoFramework

class ContractLogsSubscribeTests: XCTestCase, SubscribeContractLogsDelegate {
    
    var contractLogsCount = 0
    var echo: ECHO!
    
    override func tearDown() {
        super.tearDown()
        echo = nil
    }
    
    func didCreateLogs(logs: [ContractLogEnum]) {
        contractLogsCount += logs.count
    }
    
    func testSubscribeContractLogs() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        
        let exp = expectation(description: "testSubscribeContractLogs")
        
        //act
        echo.start { (result) in
            switch result {
            case .success(_):
                
                self.echo.subscribeToContractLogs(contractId: Constants.logsContract, delegate: self)
                
                self.echo.callContract(registrarNameOrId: Constants.defaultName,
                                       wif: Constants.defaultWIF,
                                       assetId: Constants.defaultAsset,
                                       amount: 0,
                                       assetForFee: nil,
                                       contratId: Constants.logsContract,
                                       methodName: Constants.defaultLogsContractMethod,
                                       methodParams: [AbiTypeValueInputModel.init(type: .uint(size: 256), value: "1")],
                                       sendCompletion: { (result) in
                    switch result {
                    case .success(_):
                        break
                    case .failure(let error):
                        XCTFail("Call failed \(error)")
                    }
                }, confirmNoticeHandler: { (_) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        exp.fulfill()
                    })
                })
            case .failure(let error):
                XCTFail("Starting failed \(error)")
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(self.contractLogsCount > 0)
        }
    }
}
