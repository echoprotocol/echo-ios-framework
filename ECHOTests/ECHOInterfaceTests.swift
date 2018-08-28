//
//  ECHOInterfaceTests.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 24.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class ECHOInterfaceTests: XCTestCase {
    
    var echo: ECHO!
    let timeout: Double = 20

    func testStartingLib() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
        }))
        let exp = expectation(description: "Start")
        var isStarted = false
        
        //act
        echo.start { (result) in
            switch result {
            case .success(_):
                isStarted = true
                exp.fulfill()
            case .failure(let error):
                XCTFail("Starting failed \(error)")
            }
        }
        
        //assert
        waitForExpectations(timeout: timeout) { error in
            XCTAssertEqual(isStarted, true)
        }
    }
    
    func testGettingUser() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
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
                case .failure(let error):
                    XCTFail("Getting account cant fail \(error)")
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: timeout) { error in
            XCTAssertEqual(account.name, userName)
        }
    }
    
    func testGettingAccountHistory() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
        }))
        let exp = expectation(description: "History Getting")
        let userId = "1.2.18"
        let startId = "1.11.0"
        let stopId = "1.11.0"
        let limit = 100
        var history: [HistoryItem]!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getAccountHistroy(nameOrID: userId, startId: startId, stopId: stopId, limit: limit) { (result) in
                switch result {
                case .success(let accountHistory):
                    history = accountHistory
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Getting account history cant fail \(error)")
                }
            }
        }
        
        //assert
        waitForExpectations(timeout: timeout) { error in
            XCTAssertEqual(history.count, limit)
        }
    }
    
    func testGettingAccountBalance() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
        }))
        let exp = expectation(description: "Account balances Getting")
        var accountBalaces: [AccountBalance]!
        let userName = "dima1"
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getBalance(nameOrID: userName, asset: nil, completion: { (result) in
                switch result {
                case .success(let balances):
                    accountBalaces = balances
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Getting balances cant fail \(error)")
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: timeout) { error in
            XCTAssertNotNil(accountBalaces)
        }
    }
    
    func testIsAccountReserved() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
        }))
        let exp = expectation(description: "Account Getting")
        var isAccReserved = false
        let userName = "dima1"
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.isAccountReserved(nameOrID: userName, completion: { (result) in
                switch result {
                case .success(let isReserved):
                    isAccReserved = isReserved
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Reserving checking fail \(error)")
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: timeout) { error in
            XCTAssertTrue(isAccReserved)
        }
    }    
}
