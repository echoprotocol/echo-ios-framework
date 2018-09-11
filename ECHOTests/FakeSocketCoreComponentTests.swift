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

    func testFakeTransfer() {

        //arrange
        let messenger = SocketMessengerStub(state: .transfer)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Transfer")
        let password = "P5JDUR7rSa9QXtYp9CF9HhnDRdPYz9mVpeiU812r2p5WVr8UcREY"
        let fromUser = "nikita1994"
        let toUser = "dima1"
        var isSuccess = false
        
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.sendTransferOperation(fromNameOrId: fromUser, password: password, toNameOrId: toUser, amount: 1, asset: "1.3.0", message: "", completion: { (result) in
                switch result {
                case .success(let result):
                    isSuccess = result
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Transfer must be valid \(error)")
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: 10) { error in
            XCTAssertTrue(isSuccess)
        }
    }
    
    func testFakeChangePassword() {

        //arrange
        let messenger = SocketMessengerStub(state: .changePassword)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Change password")
        let userName = "dima1"
        let password = "P5J8pDyzznMmEdiBCdgB7VKtMBuxw5e4MAJEo3sfUbxcM"
        let newPassword = "newPassword"
        var success: Bool!

        //act
        echo.start { [unowned self] (result) in
            self.echo.changePassword(old: password, new: newPassword, name: userName, completion: { (result) in
                switch result {
                case .success(let isSuccess):
                    success = isSuccess
                    exp.fulfill()
                case .failure(_):
                    XCTFail("Change password cant fail")
                }
            })
        }

        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertTrue(success)
        }
    }
    
    func testFakeIssueAsset() {
        
        //arrange
        let messenger = SocketMessengerStub(state: .issueAsset)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Issue asset")
        let issuerNameOrId = "vsharaev1"
        let password = "newTestPass"
        let asset = "1.3.87"
        let amount: UInt = 1
        let destinationIdOrName = "vsharaev2"
        let message = "Issue asset message"
        var success: Bool!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.issueAsset(issuerNameOrId: issuerNameOrId,
                                 password: password,
                                 asset: asset,
                                 amount: amount,
                                 destinationIdOrName: destinationIdOrName,
                                 message: message) { (result) in
                                
                switch result {
                case .success(let isSuccess):
                    success = isSuccess
                    exp.fulfill()
                case .failure(_):
                    XCTFail("Issue asset cant fail")
                }
            }

        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertTrue(success)
        }
    }
    
    func testFakeCreateAsset() {
        
        //arrange
        let messenger = SocketMessengerStub(state: .createAsset)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Create asset")
        var asset = Asset("")
        asset.symbol = "VSASSETFORISSUE2"
        asset.precision = 4
        asset.issuer = Account("1.2.95")
        asset.setBitsassetOptions(BitassetOptions(feedLifetimeSec: 86400,
                                                  minimumFeeds: 7,
                                                  forceSettlementDelaySec: 86400,
                                                  forceSettlementOffsetPercent: 100,
                                                  maximumForceSettlementVolume: 2000,
                                                  shortBackingAsset: "1.3.0"))
        asset.predictionMarket = false
        
        asset.options = AssetOptions(maxSupply: 100000,
                                     marketFeePercent: 0,
                                     maxMarketFee: 0,
                                     issuerPermissions: AssetOptionIssuerPermissions.committeeFedAsset.rawValue,
                                     flags: AssetOptionIssuerPermissions.committeeFedAsset.rawValue,
                                     coreExchangeRate: Price(base: AssetAmount(amount: 1, asset: Asset("1.3.0")), quote: AssetAmount(amount: 1, asset: Asset("1.3.1"))),
                                     description: "description")
        let nameOrId = "vsharaev1"
        let password = "newTestPass"
        var success: Bool!
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.createAsset(nameOrId: nameOrId, password: password, asset: asset) { (result) in
                
                switch result {
                case .success(let isSuccess):
                    success = isSuccess
                    exp.fulfill()
                case .failure(_):
                    XCTFail("Create asset cant fail")
                }
            }
            
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertTrue(success)
        }
    }
    
    func testFakeGetContract() {
        
        //arrange
        let messenger = SocketMessengerStub(state: .getContract)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Getting contracts")
        let legalContractId = "1.16.1"
        var contract: ContractStruct!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getContract(contractId: legalContractId, completion: { (result) in
                switch result {
                case .success(let res):
                    contract = res
                    exp.fulfill()
                case .failure(_):
                    XCTFail("Getting contracts result cant fail")
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertNotNil(contract)
        }
    }
    
    func testFakeGetContracts() {
        
        //arrange
        let messenger = SocketMessengerStub(state: .getContract)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Getting contracts")
        let legalContractId = "1.16.1"
        let contractsIDs = [legalContractId]
        var contracts: [ContractInfo] = []
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getContracts(contractIds: contractsIDs, completion: { (result) in
                switch result {
                case .success(let res):
                    contracts = res
                    exp.fulfill()
                case .failure(_):
                    XCTFail("Getting contracts result cant fail")
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertTrue(contracts.count == 1)
        }
    }
    
    func testFakeGetAllContracts() {
        
        //arrange
        let messenger = SocketMessengerStub(state: .getContract)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Getting contracts")
        var contracts: [ContractInfo] = []
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getAllContracts(completion: { (result) in
                switch result {
                case .success(let res):
                    contracts = res
                    exp.fulfill()
                case .failure(_):
                    XCTFail("Getting contracts result cant fail")
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertTrue(contracts.count > 0)
        }
    }
    
    func testFakeGetContractResult() {
        
        //arrange
        let messenger = SocketMessengerStub(state: .getContract)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Getting contract")
        let historyId = "1.17.2"
        var contractResult: ContractResult!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getContractResult(historyId: historyId, completion: { (result) in
                switch result {
                case .success(let res):
                    contractResult = res
                    exp.fulfill()
                case .failure(_):
                    XCTFail("Getting result cant fail")
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertNotNil(contractResult)
        }
    }
}
