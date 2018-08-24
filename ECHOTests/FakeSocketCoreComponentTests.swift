//
//  SocketCoreComponentTests.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 23.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class SocketCoreComponentTests: XCTestCase {
    
    var echo: ECHO!
    
    override func tearDown() {
        super.tearDown()
        echo = nil
    }
    
    func testConnectingToUrl() {

        //arrange
        let fakeUrl = "fakeUrl"
        let messenger = SocketMessengerStub()
        echo = ECHO(settings: Settings(build: {
                $0.network = Network(url: fakeUrl, prefix: NetworkPrefix.echo)
                $0.socketMessenger = messenger
            }))
        let exp = expectation(description: "Start with url \(fakeUrl)")

        //act
        echo.start { (result) in
            exp.fulfill()
        }

        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(messenger.connectedUrl, fakeUrl)
        }
    }
    
    func testConnectingCount() {
        
        //arrange
        let messenger = SocketMessengerStub()
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Connection count")
        
        //act
        echo.start { (result) in
            exp.fulfill()
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(messenger.connectionCount, 1)
        }
    }
    
    func testRevealingApi() {
        
        //arrange
        let messenger = SocketMessengerStub()
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
            $0.apiOptions = [.database, .networkBroadcast]
        }))
        let exp = expectation(description: "Revealing API")

        //act
        echo.start { (result) in
            exp.fulfill()
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(messenger.revealDatabaseApi, true)
            XCTAssertEqual(messenger.revealCryptoApi, false)
            XCTAssertEqual(messenger.revealNetBroadcastsApi, true)
            XCTAssertEqual(messenger.revealHistoryApi, false)
            XCTAssertEqual(messenger.revealNetNodesApi, false)
        }
    }
    
    func testRevealingAllApi() {
        
        //arrange
        let messenger = SocketMessengerStub()
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Revealing API")
        
        //act
        echo.start { (result) in
            exp.fulfill()
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(messenger.revealDatabaseApi, true)
            XCTAssertEqual(messenger.revealCryptoApi, true)
            XCTAssertEqual(messenger.revealNetBroadcastsApi, true)
            XCTAssertEqual(messenger.revealHistoryApi, true)
            XCTAssertEqual(messenger.revealNetNodesApi, true)
        }
    }
    
    func testGettingFakeAccount() {
        
        //arrange
        let messenger = SocketMessengerStub()
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Account Getting")
        var account: Account!
        let userName = "dima1"
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getAccount(nameOrID: userName, completion: { (result) in
                switch result {
                case .success(let userAccount):
                    account = userAccount
                    exp.fulfill()
                case .failure(_):
                    XCTFail("Getting fake account cant fail")
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(account.name, userName)
        }
    }
    
    func testGettingFakeAccountHistory() {
        
        //arrange
        let messenger = SocketMessengerStub()
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "History Getting")
        let userId = "1.2.18"
        let startId = "1.11.0"
        let stopId = "1.11.0"
        let limit = 100
        var history: [HistoryItem]!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getAccountHistroy(id: userId, startId: startId, stopId: stopId, limit: limit) { (result) in
                switch result {
                case .success(let accountHistory):
                    history = accountHistory
                    exp.fulfill()
                case .failure(_):
                    XCTFail("Getting fake account cant fail")
                }
            }
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(history.count, limit)
        }
    }
}
