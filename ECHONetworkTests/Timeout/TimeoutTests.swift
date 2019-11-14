//
//  TimeoutTests.swift
//  ECHONetworkTests
//
//  Created by Vladimir Sharaev on 11.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class TimeoutTests: XCTestCase {

    var echo: ECHO!
    
    override func tearDown() {
        super.tearDown()
        echo = nil
    }

    
    func testTransferTimeoutWithWIF() {
        //arrange
        let messengerMock = SocketMessengerTimeoutMock()
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.socketMessenger = messengerMock
            $0.socketRequestsTimeout = Constants.timeout / 4
        }))
        
        let exp = expectation(description: "testTransferTimeoutWithWIF")
        let fromUser = Constants.defaultName
        let wif = Constants.defaultWIF
        let toUser = Constants.defaultToName
        var wasTimeout = false
        
        //act
        echo.start { [unowned self] (result) in
            messengerMock.simulatePackageLost = true
            self.echo.sendTransferOperation(fromNameOrId: fromUser,
                                            wif: wif,
                                            toNameOrId: toUser,
                                            amount: 1,
                                            asset: Constants.defaultAsset,
                                            assetForFee: nil,
                                            completion: { (result) in
                switch result {
                case .success:
                    XCTFail("Transfer must be failed with timeout")
                case .failure(let error):
                    switch error {
                    case .timeout:
                        wasTimeout = true
                        exp.fulfill()
                    default:
                        XCTFail("Transfer must be failed with timeout")
                    }
                }
            }, noticeHandler: nil)
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(wasTimeout)
        }
    }
    
    func testTransferConnectionLostWithWIF() {
        //arrange
        let messengerMock = SocketMessengerTimeoutMock()
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.socketMessenger = messengerMock
        }))
        
        let exp = expectation(description: "testTransferConnectionLostWithWIF")
        let fromUser = Constants.defaultName
        let wif = Constants.defaultWIF
        let toUser = Constants.defaultToName
        var wasConnectionLost = false
        
        //act
        echo.start { [unowned self] (result) in
            messengerMock.simulatePackageLost = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                messengerMock.simulateDisconnect()
            }
            self.echo.sendTransferOperation(fromNameOrId: fromUser,
                                            wif: wif,
                                            toNameOrId: toUser,
                                            amount: 1,
                                            asset: Constants.defaultAsset,
                                            assetForFee: nil,
                                            completion: { (result) in
                switch result {
                case .success:
                    XCTFail("Transfer must be failed with notice connection lost")
                case .failure(let error):
                    switch error {
                    case .connectionLost:
                        wasConnectionLost = true
                        exp.fulfill()
                    default:
                        XCTFail("Transfer must be failed with connection lost")
                    }
                }
            }, noticeHandler: nil)
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(wasConnectionLost)
        }
    }
    
    func testTransferNoticeConnectionLostWithWIF() {
        //arrange
        let messengerMock = SocketMessengerTimeoutMock()
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.socketMessenger = messengerMock
        }))
        
        let exp = expectation(description: "testTransferNoticeConnectionLostWithWIF")
        let fromUser = Constants.defaultName
        let wif = Constants.defaultWIF
        let toUser = Constants.defaultToName
        var wasNoticeConnectionLost = false
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.sendTransferOperation(fromNameOrId: fromUser,
                                            wif: wif,
                                            toNameOrId: toUser,
                                            amount: 1,
                                            asset: Constants.defaultAsset,
                                            assetForFee: nil,
                                            completion: { (result) in
                switch result {
                case .success:
                    messengerMock.simulateNonResponces()
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        messengerMock.simulateDisconnect()
                    }
                case .failure:
                    XCTFail("Transfer must be failed with notice connection lost")
                }
            }, noticeHandler: { (notice) in
                switch notice {
                case .success:
                    XCTFail("Transfer must be failed with notice connection lost")
                case .failure(let error):
                    switch error {
                    case .connectionLost:
                        wasNoticeConnectionLost = true
                        exp.fulfill()
                    default:
                        XCTFail("Transfer must be failed with notice connection lost")
                    }
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(wasNoticeConnectionLost)
        }
    }
}
