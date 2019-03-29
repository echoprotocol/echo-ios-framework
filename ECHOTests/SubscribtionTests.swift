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
        let username = "1.2.22"
        
        //act
        echo.start { [unowned self] (result) in
            print(result)
            self.echo.subscribeToAccount(nameOrId: username, delegate: delegate)
            messenger.makeUserAccountChangePasswordEvent()
            exp.fulfill()
        }
        
        //assert
        waitForExpectations(timeout: timeout) { error in
            XCTAssertEqual(delegate.delegateEvents, 1)
        }
    }
    
    func testUnretainedSubscribe() {
        
        //arrange
        let messenger = SocketMessengerStub(state: .subscribeToAccount)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let userName = "vsharaev"
        
        strongDelegate = SubscribeAccountDelegateStub()
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
        let messenger = SocketMessengerStub(state: .subscribeToAccount)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let userName = "1.2.22"
        let delegate = SubscribeAccountDelegateStub()
        strongDelegate = delegate
        let exp = expectation(description: "Delegate Call")
        
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.subscribeToAccount(nameOrId: userName, delegate: delegate)
            messenger.makeUserAccountTransferChangeEvent()
            exp.fulfill()
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
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .accountHistory]
        }))
        
        // Logs
        let exp = expectation(description: "Contract logs")
        let delegate = SubscribeContractLogsDelegateStub(exp: exp)
        strongContractLogDelegate = delegate
        
        // Call for change logs
        let registrarNameOrId = "vsharaev"
        let password = "vsharaev"
        let assetId = "1.3.0"
        let contratId = "1.16.141"
        let methodName = "test"
        let params: [AbiTypeValueInputModel] = [AbiTypeValueInputModel(type: .uint(size: 256), value: "1")]
        
        //act
        echo.start { [unowned self] (result) in
            
            delegate.addSubscribe(contractId: contratId)
            self.echo.subscribeToContractLogs(contractId: contratId, delegate: delegate)
            
            self.echo.callContract(registrarNameOrId: registrarNameOrId,
                                   passwordOrWif: PassOrWif.password(password),
                                   assetId: assetId,
                                   amount: nil,
                                   assetForFee: nil,
                                   contratId: contratId,
                                   methodName: methodName,
                                   methodParams: params,
                                   completion: { (result) in
                                    
                switch result {
                case .success(_):
                    print("Logs must be changed")
                case .failure(let error):
                    XCTFail("Change logs cant fail \(error)")
                }
            }, noticeHandler: nil)
        }
        
        //assert
        waitForExpectations(timeout: timeout) { error in
            XCTAssertEqual(delegate.delegateEvents, 1)
            XCTAssertEqual(delegate.rightDelegateEvents, 1)
        }
    }
}
