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
        let messenger = SocketMessengerStub(state: .reveal)
        echo = ECHO(settings: Settings(build: {
            $0.network = ECHONetwork(url: fakeUrl, prefix: ECHONetworkPrefix.echo, echorandPrefix: .echo)
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
        let messenger = SocketMessengerStub(state: .reveal)
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
        let messenger = SocketMessengerStub(state: .reveal)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
            $0.apiOptions = [.database, .networkBroadcast, .registration]
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
            XCTAssertEqual(messenger.registrationApi, false)
        }
    }
    
    func testRevealingAllApi() {
        
        //arrange
        let messenger = SocketMessengerStub(state: .reveal)
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
        let messenger = SocketMessengerStub(state: .getAccount)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Account Getting")
        var account: Account!
        let userName = "vsharaev"
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getAccount(nameOrID: userName, completion: { (result) in
                switch result {
                case .success(let userAccount):
                    account = userAccount
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Getting fake account cant fail \(error)")
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: 10) { error in
            XCTAssertEqual(account?.name, userName)
        }
    }

    func testFakeTransfer() {

        //arrange
        let messenger = SocketMessengerStub(state: .transfer)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Transfer")
        let fromUser = "vsharaev"
        let password = "vsharaev"
        let toUser = "vsharaev"
        var isSuccess = false
        
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.sendTransferOperation(fromNameOrId: fromUser,
                                            passwordOrWif: PassOrWif.password(password),
                                            toNameOrId: toUser,
                                            amount: 1,
                                            asset: "1.3.0",
                                            assetForFee: nil,
                                            completion: { (result) in
                                                
                switch result {
                case .success(let result):
                    isSuccess = result
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Transfer must be valid \(error)")
                }
            }, noticeHandler: nil)
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
        let userName = "vsharaev"
        let password = "vsharaev"
        let newPassword = "newPassword"
        var success: Bool!

        //act
        echo.start { [unowned self] (result) in
            self.echo.changePassword(old: password, new: newPassword, name: userName, completion: { (result) in
                switch result {
                case .success(let isSuccess):
                    success = isSuccess
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Change password cant fail \(error)")
                }
            })
        }

        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertNotNil(success)
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
        let issuerNameOrId = "vsharaev"
        let password = "vsharaev"
        let asset = "1.3.1"
        let amount: UInt = 1
        let destinationIdOrName = "vsharaev"
        var success: Bool!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.issueAsset(issuerNameOrId: issuerNameOrId,
                                 passwordOrWif: PassOrWif.password(password),
                                 asset: asset,
                                 amount: amount,
                                 destinationIdOrName: destinationIdOrName) { (result) in
                                
                switch result {
                case .success(let isSuccess):
                    success = isSuccess
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Issue asset cant fail \(error)")
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
        let nameOrId = "vsharaev"
        let password = "vsharaev"
        var success: Bool!
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.createAsset(nameOrId: nameOrId,
                                  passwordOrWif: PassOrWif.password(password),
                                  asset: asset) { (result) in
                
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
        let legalContractId = "1.14.56"
        var contract: ContractStructEnum!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getContract(contractId: legalContractId, completion: { (result) in
                switch result {
                case .success(let res):
                    contract = res
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Getting contracts result cant fail \(error)")
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
        let legalContractId = "1.14.56"
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
    
    func testFakeCreateContract() {

        //arrange
        let messenger = SocketMessengerStub(state: .createContract)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Creating contract")
        let byteCode =  "60806040526000805534801561001457600080fd5b5061010180610024" +
                        "6000396000f3006080604052600436106053576000357c010000000000" +
                        "0000000000000000000000000000000000000000000000900463fffff" +
                        "fff1680635b34b966146058578063a87d942c14606c578063f5c5ad8" +
                        "3146094575b600080fd5b348015606357600080fd5b50606a60a" +
                        "8565b005b348015607757600080fd5b50607e60ba565b6040518" +
                        "082815260200191505060405180910390f35b348015609f57600" +
                        "080fd5b5060a660c3565b005b600160008082825401925050819" +
                        "05550565b60008054905090565b6001600080828254039250508" +
                        "19055505600a165627a7a7230582063e27ea8b308defeeb50719" +
                        "f281e50a9b53ffa155e56f3249856ef7eafeb09e90029"
        var success = false

        //act
        echo.start { (result) in
            self.echo.createContract(registrarNameOrId: "vsharaev",
                                     passwordOrWif: PassOrWif.password("vsharaev"),
                                     assetId: "1.3.0",
                                     amount: nil,
                                     assetForFee: nil,
                                     byteCode: byteCode,
                                     supportedAssetId: nil,
                                     ethAccuracy: false,
                                     parameters: nil,
                                     completion: { (result) in

                switch result {
                case .success(let isSuccess):
                    success = isSuccess
                    exp.fulfill()
                case .failure(_):
                    XCTFail("Creating contract cant fail")
                }
            }, noticeHandler: { (notice) in
                
            })
        }

        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertTrue(success)
        }
    }
    
    func testFakeCreateContractWithParameters() {
        
        //arrange
        let messenger = SocketMessengerStub(state: .createContract)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Creating contract")
        let byteCode =  "60806040526000805534801561001457600080fd5b5061011480610024" +
            "6000396000f300608060405260043610605c5763ffffffff7c010000000000000000000000000000000000" +
            "00000000000000000000006000350416635b34b966811460615780635b9af12b146075578063a87d942c14" +
            "608a578063f5c5ad831460ae575b600080fd5b348015606c57600080fd5b50607360c0565b005b34801560" +
            "8057600080fd5b50607360043560cb565b348015609557600080fd5b50609c60d6565b6040805191825251" +
            "9081900360200190f35b34801560b957600080fd5b50607360dc565b600080546001019055565b60008054" +
            "9091019055565b60005490565b600080546000190190555600a165627a7a7230582016b3f6673de41336e2" +
        "c5d4b136b4e67bbf43062b6bc47eaef982648cd3b92a9d0029"
        
        let parameters = [AbiTypeValueInputModel(type: .uint(size: 256), value: "123"),
                          AbiTypeValueInputModel(type: .string, value: "Hello, World!")]
        var success = false
        
        //act
        echo.start { (result) in
            
            self.echo.createContract(registrarNameOrId: "vsharaev",
                                     passwordOrWif: PassOrWif.password("vsharaev"),
                                     assetId: "1.3.0",
                                     amount: nil,
                                     assetForFee: nil,
                                     byteCode: byteCode,
                                     supportedAssetId: nil,
                                     ethAccuracy: false,
                                     parameters: parameters,
                                     completion: { (result) in
                switch result {
                case .success(let isSuccess):
                    success = isSuccess
                    exp.fulfill()
                case .failure(_):
                    XCTFail("Creating contract cant fail")
                }
            }, noticeHandler: { (notice) in
                
            })
        }
        
        //assert
        waitForExpectations(timeout: 1000) { error in
            XCTAssertTrue(success)
        }
    }
    
    func testFakeQueryContract() {
        
        //arrange
        let messenger = SocketMessengerStub(state: .queryContract)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Query contract")
        let registrarNameOrId = "vsharaev"
        let assetId = "1.3.0"
        let contratId = "1.14.1"
        let methodName = "getCount"
        let params: [AbiTypeValueInputModel] = []
        var query: String!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.queryContract(registrarNameOrId: registrarNameOrId, assetId: assetId, contratId: contratId, methodName: methodName, methodParams: params) { (result) in
                
                switch result {
                case .success(let res):
                    query = res
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Query contract cant fail \(error)")
                }
            }
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertNotNil(query)
        }
    }
    
    func testFakeCallContract() {

        //arrange
        let messenger = SocketMessengerStub(state: .callContract)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Call contract")
        let registrarNameOrId = "vsharaev"
        let password = "vsharaev"
        let assetId = "1.3.0"
        let contratId = "1.14.56"
        let methodName = "incrementCounter"
        let params: [AbiTypeValueInputModel] = []
        var success = false

        //act
        echo.start { [unowned self] (result) in
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
                case .success(let isSuccess):
                    success = isSuccess
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Call contract cant fail \(error)")
                }
            }, noticeHandler: { (notice) in
                
            })
        }

        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertTrue(success)
        }
    }
    
    func testFakeGetBlock() {
        
        //arrange
        let messenger = SocketMessengerStub(state: .getBlock)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "Get block")
        let blockNum = 1377170
        var block: Block!
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.getBlock(blockNumber: blockNum, completion: { (result) in
                
                switch result {
                case .success(let res):
                    block = res
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Get block can't fail \(error)")
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertNotNil(block)
        }
    }
    
    func testFakeCreateEthAddress() {
        
        //arrange
        let messenger = SocketMessengerStub(state: .createEthAddress)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "testFakeCreateEthAddress")
        var success: Bool!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.generateEthAddress(nameOrId: "vsharaev",
                                         passwordOrWif: .password("vsharaev"),
                                         assetForFee: nil,
                                         completion: { (result) in
                                            
                switch result {
                case .success(let res):
                    success = res
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Create eth address can't fail \(error)")
                }
            }, noticeHandler: nil)
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertNotNil(success)
        }
    }
    
    func testFakeGetEthAddress() {
        
        //arrange
        let messenger = SocketMessengerStub(state: .getEthAddress)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "testFakeGetEthAddress")
        var addresses: EthAddress?
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getEthAddress(nameOrId: "vsharaev", completion: { (result) in
                switch result {
                case .success(let res):
                    addresses = res
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Get eth address can't fail \(error)")
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertNotNil(addresses)
        }
    }
    
    func testFakeWithdrawalEth() {
        
        //arrange
        let messenger = SocketMessengerStub(state: .createEthAddress)
        echo = ECHO(settings: Settings(build: {
            $0.socketMessenger = messenger
        }))
        let exp = expectation(description: "testFakeWithdrawalEth")
        var success: Bool!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.withdrawalEth(nameOrId: "vsharaev",
                                    passwordOrWif: .password("vsharaev"),
                                    toEthAddress: "0x46Ba2677a1c982B329A81f60Cf90fBA2E8CA9fA8",
                                    amount: 1,
                                    assetForFee: nil,
                                    completion: { (result) in
                
                switch result {
                case .success(let res):
                    success = res
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Create eth address can't fail \(error)")
                }
            }, noticeHandler: nil)
        }
        
        //assert
        waitForExpectations(timeout: 1) { error in
            XCTAssertNotNil(success)
        }
    }
}
