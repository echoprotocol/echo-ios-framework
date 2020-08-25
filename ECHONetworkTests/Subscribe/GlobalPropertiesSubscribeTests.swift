//
//  GlobalPropertiesSubscribeTests.swift
//  ECHONetworkTests
//
//  Created by Vladimir Sharaev on 11.11.2019.
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
            $0.debug = true
        }))
        
        let exp = expectation(description: "testSubscribeDynamicGlobalProperties")
        
        //act
        echo.start { (result) in
            switch result {
            case .success(_):
                
                self.echo.subscribeToDynamicGlobalProperties(delegate: self)

                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.echo.sendTransferOperation(fromNameOrId: Constants.defaultName,
                                                    wif: Constants.defaultWIF,
                                                    toNameOrId: Constants.defaultToName,
                                                    amount: 1, asset: Constants.defaultAsset,
                                                    assetForFee: nil,
                                                    sendCompletion: { _ in},
                                                    confirmNoticeHandler: nil)
                })
                
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.timeout, execute: {
                    exp.fulfill()
                })
            case .failure(let error):
                XCTFail("testSubscribeDynamicGlobalProperties \(error)")
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout * 2) { error in
            XCTAssertTrue(self.propertiesUpdateCount > 0)
        }
    }
}
