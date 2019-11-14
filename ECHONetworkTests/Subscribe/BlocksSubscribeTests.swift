//
//  BlocksSubscribeTests.swift
//  ECHONetworkTests
//
//  Created by Vladimir Sharaev on 11.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

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