//
//  ContractsSubscribeTests.swift
//  ECHONetworkTests
//
//  Created by Vladimir Sharaev on 18/05/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class GlobalPropertiesSubscribeTests: XCTestCase, SubscribeDynamicGlobalPropertiesDelegate {
    
    var propertiesUpdateCount = 0
    var echo: ECHO!
    
    override func tearDown() {
        super.tearDown()
        echo = nil
    }
    
    func didUpdateDynamicGlobalProperties(dynamicGlobalProperties: DynamicGlobalProperties) {
        propertiesUpdateCount += 1
    }
    
    func testSubscribeDynamicGlobalProperties() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
        }))
        
        let exp = expectation(description: "testSubscribeDynamicGlobalProperties")
        
        //act
        echo.start { (result) in
            switch result {
            case .success(_):
                
                self.echo.subscribeToDynamicGlobalProperties(delegate: self)

                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    exp.fulfill()
                })
            case .failure(let error):
                XCTFail("testSubscribeDynamicGlobalProperties \(error)")
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(self.propertiesUpdateCount > 0)
        }
    }
}

class BlocksSubscribeTests: XCTestCase, SubscribeBlockDelegate {
    
    var blockCreateCount = 0
    var echo: ECHO!
    
    override func tearDown() {
        super.tearDown()
        echo = nil
    }
    
    func didCreateBlock(block: Block) {
        blockCreateCount += 1
    }
    
    func testSubscribeBlocks() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
        }))
        
        let exp = expectation(description: "testSubscribeBlocks")
        
        //act
        echo.start { (result) in
            switch result {
            case .success(_):
                
                self.echo.subscribeToBlock(delegate: self)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                    exp.fulfill()
                })
            case .failure(let error):
                XCTFail("testSubscribeBlocks \(error)")
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(self.blockCreateCount > 0)
        }
    }
}

class AccountSubscribeTests: XCTestCase, SubscribeAccountDelegate {
    
    var accountUpdatesCount = 0
    var echo: ECHO!
    
    override func tearDown() {
        super.tearDown()
        echo = nil
    }
    
    func didUpdateAccount(userAccount: UserAccount) {
        accountUpdatesCount += 1
    }
    
    func testSubscribeAcount() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
        }))
        
        let exp = expectation(description: "testSubscribeAcount")
        
        //act
        echo.start { (result) in
            switch result {
            case .success(_):
                
                self.echo.subscribeToAccount(nameOrId: Constants.defaultName, delegate: self)
                
                self.echo.sendTransferOperation(fromNameOrId: Constants.defaultName,
                                                wif: Constants.defaultWIF,
                                                toNameOrId: Constants.defaultToName,
                                                amount: 1, asset: Constants.defaultAsset,
                                                assetForFee: nil,
                                                completion: { (result) in
                    switch result {
                    case .success(_):
                        break
                    case .failure(let error):
                        XCTFail("testSubscribeAcount \(error)")
                    }
                }) { (_) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        exp.fulfill()
                    })
                }
            case .failure(let error):
                XCTFail("testSubscribeAcount \(error)")
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(self.accountUpdatesCount > 0)
        }
    }
}

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
            XCTAssertTrue(self.contractLogsCount > 0)
        }
    }
}

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
        
        let exp = expectation(description: "testStartingLib")
        
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
