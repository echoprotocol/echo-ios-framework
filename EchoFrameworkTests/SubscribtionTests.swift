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
    let timeout: Double = 20
    var strongDelegate: SubscribeAccountDelegateStub?
    var strongContractLogDelegate: SubscribeContractLogsDelegateStub?
    
    override func tearDown() {
        super.tearDown()
        strongDelegate = nil
        strongContractLogDelegate = nil
    }
    
    func testSubscribe() {
  
        //arrange
        let messenger = SocketMessengerStub(state: .subscribeToAccount)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        
        let delegate = SubscribeAccountDelegateStub()
        strongDelegate = delegate
        let exp = expectation(description: "Delegate Call")
        let username = "1.2.48"
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.subscribeToAccount(nameOrId: username, delegate: delegate)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                messenger.makeUserAccountTransferChangeEvent()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    exp.fulfill()
                }
            }
        }
        
        //assert
        waitForExpectations(timeout: timeout) { error in
            XCTAssertEqual(delegate.delegateEvents, 2)
        }
    }
    
    func testUnsubscribe() {
        
        //arrange
        let messenger = SocketMessengerStub(state: .subscribeToAccount)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let userName = "vsharaev"
        let delegate = SubscribeAccountDelegateStub()
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
        let messenger = SocketMessengerStub(state: .subscribeToAccount)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let userName = "vsharaev"
        let delegate = SubscribeAccountDelegateStub()
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
    
    func testSubscribeContractLogs() {
        
        //arrange
        let messenger = SocketMessengerStub(state: .subscribeToConsractLogs)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        
        // Logs
        let exp = expectation(description: "Contract logs")
        let delegate = SubscribeContractLogsDelegateStub(exp: exp)
        strongContractLogDelegate = delegate
        
        let contratId = "1.11.804"
        
        //act
        echo.start { [unowned self] (result) in
            
            delegate.addSubscribe(contractId: contratId)
            self.echo.subscribeToContractLogs(contractId: contratId, delegate: delegate)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                messenger.makeContractLogCreateEvent()
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    exp.fulfill()
                }
            }
        }
        
        //assert
        waitForExpectations(timeout: timeout) { error in
            XCTAssertEqual(delegate.delegateEvents, 1)
            XCTAssertEqual(delegate.rightDelegateEvents, 1)
        }
    }
}
