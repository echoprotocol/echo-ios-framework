//
//  SubscribtionTests.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 28.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO


class SubscribtionTests: XCTestCase {
    
    var echo: ECHO!
    var strongDelegate: SubscribeDelegateMock?
    
    override func tearDown() {
        super.tearDown()
        strongDelegate = nil
    }
    
    class SubscribeDelegateMock: SubscribeAccountDelegate {
        
        var subscribeNameOrIds = [String]()
        var delegateEvents = 0
        var rightDelegateEvents = 0
        
        func didUpdateAccount(userAccount: UserAccount) {
            
            delegateEvents += 1
            
            if let _ = subscribeNameOrIds.first(where: {userAccount.account.id == $0 && userAccount.account.name == $0 }) {
                rightDelegateEvents += 1
            }
        }
        
        func addSubscribe(nameOrId: String) {
            subscribeNameOrIds.append(nameOrId)
        }
        
        deinit {
            print("DEINIT")
        }
    }
    
    func testSubscribe() {
  
        //arrange
        let messenger = SocketMessengerStub(state: .subscribe)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let userName = "nikita1994"
        let delegate = SubscribeDelegateMock()
        strongDelegate = delegate
        let exp = expectation(description: "Delegate Call")

        
        //act
        echo.start { [unowned self] (result) in
            print(result)
            self.echo.subscribeToAccount(nameOrId: userName, delegate: delegate)
            messenger.makeUserAccountChangePasswordEvent()
            exp.fulfill()
        }
        
        //assert
        waitForExpectations(timeout: 1000) { error in
            XCTAssertEqual(delegate.delegateEvents, 1)
        }
    }
    
    func testUnretainedSubscribe() {
        
        //arrange
        let messenger = SocketMessengerStub()
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let userName = "nikita1994"
        
        strongDelegate = SubscribeDelegateMock()
        weak var delegate = strongDelegate

        let exp = expectation(description: "Delegate Call")
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.subscribeToAccount(nameOrId: userName, delegate: self.strongDelegate!)
            self.strongDelegate = nil
            exp.fulfill()
        }

        //assert
        waitForExpectations(timeout: 1) { [weak delegate] error in
            XCTAssertNil(delegate, "Delegate must be released")
        }
    }
    
    func testSubscribe2() {
        
        //arrange
        let messenger = SocketMessengerStub(state: .subscribe)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let userName = "nikita1994"
        let delegate = SubscribeDelegateMock()
        strongDelegate = delegate
        let exp = expectation(description: "Delegate Call")
        
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.subscribeToAccount(nameOrId: userName, delegate: delegate)
            messenger.makeUserAccountTransferChangeEvent()
            exp.fulfill()
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(delegate.delegateEvents, 1)
        }
    }
    
    func testUnsubscribe() {
        
        //arrange
        let messenger = SocketMessengerStub()
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let userName = "nikita1994"
        let delegate = SubscribeDelegateMock()
        strongDelegate = delegate
        let exp = expectation(description: "Delegate Call")
        
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.subscribeToAccount(nameOrId: userName, delegate: delegate)
            self.echo.unsubscribeToAccount(nameOrId: userName, delegate: delegate)
            messenger.makeUserAccountTransferChangeEvent()
            exp.fulfill()
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(delegate.delegateEvents, 0)
        }
    }
        
    func testUnsubscribeAll() {
        //arrange
        let messenger = SocketMessengerStub()
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let userName = "nikita1994"
        let delegate = SubscribeDelegateMock()
        strongDelegate = delegate
        let exp = expectation(description: "Delegate Call")
        
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.subscribeToAccount(nameOrId: userName, delegate: delegate)
            self.echo.unsubscribeAll()
            messenger.makeUserAccountTransferChangeEvent()
            exp.fulfill()
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertEqual(delegate.delegateEvents, 0)
        }
    }
}
