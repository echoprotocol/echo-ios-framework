//
//  AccountSubscribeTests.swift
//  ECHONetworkTests
//
//  Created by Vladimir Sharaev on 11.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import XCTest
@testable import EchoFramework

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
            $0.debug = true
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
                                                sendCompletion: { (result) in
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
