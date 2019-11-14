//
//  ContractsSubscribeTests.swift
//  ECHONetworkTests
//
//  Created by Vladimir Sharaev on 18/05/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class ContractsSubscribeTests: XCTestCase, SubscribeContractsDelegate {
    
    var contractsEventsCount: Int = 0
    var contractsHistoryEventsCount: Int = 0
    var echo: ECHO!
    
    override func tearDown() {
        super.tearDown()
        echo = nil
        contractsEventsCount = 0
        contractsHistoryEventsCount = 0
    }
    
    func contractUpdated(contract: Contract) {
        contractsEventsCount += 1
    }
    
    func contractHistoryCreated(historyObject: ContractHistory) {
        contractsHistoryEventsCount += 1
    }
    
    func testSubscribeContracts() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
        }))
        
        let exp = expectation(description: "testSubscribeContracts")
        
        //act
        echo.start { (result) in
            switch result {
            case .success(_):
                
                self.echo.subscribeContracts(contractsIds: [Constants.logsContract], delegate: self)
                
                self.echo.callContract(registrarNameOrId: Constants.defaultName,
                                       wif: Constants.defaultWIF,
                                       assetId: Constants.defaultAsset,
                                       amount: 0,
                                       assetForFee: nil,
                                       contratId: Constants.logsContract,
                                       methodName: Constants.defaultLogsContractMethod,
                                       methodParams: [AbiTypeValueInputModel.init(type: .uint(size: 256), value: "1")],
                                       completion: { (result) in
                    switch result {
                    case .success(_):
                        break
                    case .failure(let error):
                        XCTFail("Call failed \(error)")
                    }
                }, noticeHandler: { (_) in
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
            XCTAssertTrue(self.contractsHistoryEventsCount > 0)
        }
    }
}
