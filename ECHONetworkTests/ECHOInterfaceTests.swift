//
//  ECHOInterfaceTests.swift
//  ECHONetworkTests
//
//  Created by Fedorenko Nikita on 24.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class ECHOInterfaceTests: XCTestCase {
    
    var echo: ECHO!
    
    override func tearDown() {
        super.tearDown()
        echo = nil
    }

    func testStartingLib() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testStartingLib")
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
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertEqual(isStarted, true)
        }
    }
    
    func testStartingLibInvalidUrl() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: "Fake network url", prefix: .bitshares, echorandPrefix: .echo)
        }))
        let exp = expectation(description: "testStartingLibInvalidUrl")
        var isStarted = false
        
        //act
        echo.start { (result) in
            switch result {
            case .success(_):
                isStarted = true
                XCTFail("Cant start with fake url")
            case .failure(_):
                isStarted = false
                exp.fulfill()
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertEqual(isStarted, false)
        }
    }
    
    func testStartingLibBrokenUrl() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: "fake url", prefix: ECHONetworkPrefix.bitshares, echorandPrefix: .echo)
        }))
        let exp = expectation(description: "testStartingLibBrokenUrl")
        var isStarted = false
        
        //act
        echo.start { (result) in
            switch result {
            case .success(_):
                isStarted = true
                XCTFail("Cant start with fake url")
            case .failure(_):
                isStarted = false
                exp.fulfill()
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertEqual(isStarted, false)
        }
    }

//    func testRegisterUser() {
//        //arrange
//        echo = ECHO(settings: Settings(build: {
//            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory, .registration]
//            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
//            $0.debug = true
//        }))
//        let exp = expectation(description: "testRegisterUser")
//        let userName = Constants.defaultToName
//        let wif = Constants.defaultWIF
//        var finalResult = false
//
//        //act
//        echo.start { [unowned self] (result) in
//            self.echo.registerAccount(
//                name: userName,
//                wif: wif,
//                evmAddress: nil,
//                sendCompletion: { (result) in
//                    switch result {
//                    case .success:
//                        finalResult = true
//                    case .failure(let error):
//                        XCTFail("Getting account cant fail \(error)")
//                    }
//                },
//                confirmNoticeHandler: { notice in
//                    exp.fulfill()
//                }
//            )
//        }
//
//        //assert
//        waitForExpectations(timeout: Constants.timeout * 3) { error in
//            XCTAssertEqual(finalResult, true)
//        }
//    }
    
    func testRegisterUserWithInvalidEVMAddress() {
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory, .registration]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testRegisterUserWithInvalidEVMAddress")
        let userName = Constants.defaultToName + "test1"
        let wif = Constants.defaultWIF
        var errorMessage: String?

        //act
        echo.start { [unowned self] (result) in
            self.echo.registerAccount(
                name: userName,
                wif: wif,
                evmAddress: Constants.defaultETHAddress + "1",
                sendCompletion: { (result) in
                    
                switch result {
                case .success:
                    XCTFail("Register new account must fail")
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    exp.fulfill()
                }
            }, confirmNoticeHandler: { notice in
                switch notice {
                case .success:
                    XCTFail("Register new account must fail")
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
                exp.fulfill()
            })
        }

        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(errorMessage)
        }
    }
    
    func testRegisterRegisteredUser() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory, .registration]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testRegisterRegisteredUser")
        let userName = Constants.defaultName
        let wif = Constants.defaultWIF
        var errorMessage: String?
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.registerAccount(name: userName, wif: wif, evmAddress: nil, sendCompletion: { (result) in
                switch result {
                case .success(_):
                    XCTFail("Register new account must fail")
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    exp.fulfill()
                }
            }, confirmNoticeHandler: nil)
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(errorMessage)
        }
    }
    
    func testGettingUser() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGettingUser")
        var account: Account?
        let userName = Constants.defaultName
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getAccount(nameOrID: userName, completion: { (result) in
                switch result {
                case .success(let userAccount):
                    account = userAccount
                case .failure(let error):
                    XCTFail("Getting account cant fail \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertEqual(account?.name, userName)
        }
    }
    
    func testGettingUserFailed() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGettingUserFailed")
        let userName = "vsharaev new account unreserved"
        var errorMessage: String?

        //act
        echo.start { [unowned self] (result) in
            self.echo.getAccount(nameOrID: userName, completion: { (result) in
                switch result {
                case .success(_):
                    XCTFail("Getting new account must fail")
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(errorMessage)
        }
    }
    
    func testGettingAccountHistory() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGettingAccountHistory")
        let userId = Constants.defaultName
        let startId = "1.6.0"
        let stopId = "1.6.0"
        let limit = 100
        var history: [HistoryItem]!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getAccountHistroy(nameOrID: userId,
                                        startId: startId,
                                        stopId: stopId,
                                        limit: limit) { (result) in
                switch result {
                case .success(let accountHistory):
                    history = accountHistory
//                    for element in history {
//                        if let operation = element.operation {
//                            if let withdrawERC20 = operation as? SidechainERC20WithdrawTokenOperation {
//                                print(withdrawERC20)
//                            }
//                        } else {
//                            print(element)
//                        }
//                        if element.timestamp != nil {
//                            print(element.timestamp!)
//                        } else {
//                            print("asdfasdf")
//                        }
//                    }
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Getting account history cant fail \(error)")
                }
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(history?.count ?? 0 > 0)
        }
    }
    
    func testGettingAccountHistoryFailed() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGettingAccountHistoryFailed")
        let userId = "1.2.1234567"
        let startId = "1.6.0"
        let stopId = "1.6.0"
        let limit = 100
        var errorMessage: String?

        //act
        echo.start { [unowned self] (result) in
            self.echo.getAccountHistroy(nameOrID: userId, startId: startId, stopId: stopId, limit: limit) { (result) in
                switch result {
                case .success(_):
                    XCTFail("Getting account history with new account must fail")
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
                exp.fulfill()
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(errorMessage)
        }
    }
    
    func testGettingAccountBalance() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGettingAccountBalance")
        var accountBalaces: [AccountBalance]!
        let userName = Constants.defaultName
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getBalance(nameOrID: userName, asset: nil, completion: { (result) in
                switch result {
                case .success(let balances):
                    accountBalaces = balances
                case .failure(let error):
                    XCTFail("Getting balances cant fail \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(accountBalaces)
        }
    }
    
    func testGettingAccountBalanceFailed() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        var errorMessage: String?
        let exp = expectation(description: "testGettingAccountBalanceFailed")
        let userName = "new account unreserved"

        //act
        echo.start { [unowned self] (result) in
            self.echo.getBalance(nameOrID: userName, asset: nil, completion: { (result) in
                switch result {
                case .success(_):
                    XCTFail("Getting balances with new account must fail")
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(errorMessage)
        }
    }
    
    func testIsAccountReserved() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testIsAccountReserved")
        var isAccReserved = false
        let userName = Constants.defaultName
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.isAccountReserved(nameOrID: userName, completion: { (result) in
                switch result {
                case .success(let isReserved):
                    isAccReserved = isReserved
                case .failure(let error):
                    XCTFail("Reserving checking fail \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(isAccReserved)
        }
    }
    
    func testIsAccountReservedWithNewUser() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testIsAccountReservedWithNewUser")
        var isAccReserved = false
        let userName = "new account unreserved"
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.isAccountReserved(nameOrID: userName, completion: { (result) in
                switch result {
                case .success(let isReserved):
                    isAccReserved = isReserved
                case .failure(let error):
                    XCTFail("Reserving checking fail \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertFalse(isAccReserved)
        }
    }
    
    func testIsOwnedBy() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testIsOwnedBy")
        var owned = false
        let userName = Constants.defaultName
        let wif = Constants.defaultWIF
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.isOwnedBy(name: userName, wif: wif, completion: { (result) in
                switch result {
                case .success(_):
                    owned = true
                case .failure(let error):
                    XCTFail("Reserving checking fail \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(owned)
        }
    }
    
    func testIsOwnedByFailed() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testIsOwnedByFailed")
        var owned = false
        let userName = Constants.defaultName
        let wif = "5JfJJX6gbAmGWc7C4vvtCRGzRa7Q6jcpiWPvMDei1KpYyfp49cf"
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.isOwnedBy(name: userName, wif: wif, completion: { (result) in
                switch result {
                case .success(_):
                    owned = true
                case .failure(_):
                    owned = false
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertFalse(owned)
        }
    }
    
    func testIsOwnedByWIF() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testIsOwnedByWIF")
        let name = Constants.defaultName
        let wif = Constants.defaultWIF
        var findedAccount: UserAccount!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.isOwnedBy(wif: wif, completion: { (result) in
                switch result {
                case .success(let accounts):
                    let account = accounts.first(where: { (account) -> Bool in
                        return account.account.name == name
                    })
                    findedAccount = account
                case .failure(let error):
                    XCTFail("Fail check is owned by WIF \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(findedAccount)
        }
    }
    
    func testIsOwnedByWIFAccountNotCreated() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testIsOwnedByWIFAccountNotCreated")
        let wif = "5K5bYzgBvQqWxMTMRAWchJMCre8zyRMDcENd2wq7eaXGpJbwfRJ"
        var count = -1
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.isOwnedBy(wif: wif, completion: { (result) in
                switch result {
                case .success(let accounts):
                    count = accounts.count
                case .failure(let error):
                    XCTFail("Fail check is owned by WIF \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertEqual(count, 0)
        }
    }
    
    func testIsOwnedByWIFFailedWIF() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testIsOwnedByWIFFailedWIF")
        let wif = Constants.defaultWIF + "abc"
        var wasInvalidWIF = false
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.isOwnedBy(wif: wif, completion: { (result) in
                switch result {
                case .success(_):
                    XCTFail("WIF incorrect, must be error")
                case .failure(let error):
                    switch error {
                    case .invalidWIF:
                        wasInvalidWIF = true
                    default:
                        print("Must be wasInvalidCredintials error. but \(error)")
                    }
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(wasInvalidWIF)
        }
    }
    
    func testGetFee() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetFee")
        let fromUser = Constants.defaultName
        let toUser = Constants.defaultToName
        var fee: AssetAmount!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getFeeForTransferOperation(fromNameOrId: fromUser,
                                                 toNameOrId: toUser,
                                                 amount: 1,
                                                 asset: Constants.defaultAsset,
                                                 assetForFee: nil,
                                                 completion: { (result) in
                switch result {
                case .success(let aFee):
                    fee = aFee
                case .failure(let error):
                    XCTFail("Fee getting failed \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(fee)
        }
    }
    
    func testGetFeeInAnotherAsset() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetFeeInAnotherAsset")
        let fromUser = Constants.defaultName
        let toUser = Constants.defaultToName
        let assetForFee = Constants.defaultAnotherAsset
        var fee: AssetAmount!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getFeeForTransferOperation(fromNameOrId: fromUser,
                                                 toNameOrId: toUser,
                                                 amount: 1,
                                                 asset: Constants.defaultAsset,
                                                 assetForFee: assetForFee,
                                                 completion: { (result) in
                switch result {
                case .success(let aFee):
                    fee = aFee
                case .failure(let error):
                    XCTFail("Fee getting failed \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(fee)
            XCTAssertEqual(fee?.asset.id, assetForFee)
        }
    }
    
    func testGetFeeFailed() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetFeeFailed")
        let fromUser = Constants.defaultName + "someString"
        let toUser = Constants.defaultName
        var userError: Error!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getFeeForTransferOperation(fromNameOrId: fromUser,
                                                 toNameOrId: toUser,
                                                 amount: 1,
                                                 asset: Constants.defaultAsset,
                                                 assetForFee: nil,
                                                 completion: { (result) in
                switch result {
                case .success(_):
                    XCTFail("Getting fee for transfer with undefining user must fail")
                case .failure(let error):
                    userError = error
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(userError)
        }
    }
    
    func testGetFeeForCreateContract() {
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetFeeForCreateContract")
        var fee: AssetAmount!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getFeeForCreateContract(registrarNameOrId: Constants.defaultName,
                                              assetId: Constants.defaultAsset,
                                              amount: 0, assetForFee: nil,
                                              byteCode: Constants.counterContractByteCode,
                                              supportedAssetId: nil,
                                              ethAccuracy: false,
                                              parameters: nil) { (result) in
                switch result {
                case .success(let aFee):
                    fee = aFee
                case .failure(let error):
                    XCTFail("Fee for call contract getting failed \(error)")
                }
                exp.fulfill()
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(fee)
        }
    }
    
    func testGetFeeForCreateContractByCode() {
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetFeeForCreateContractByCode")
        var fee: AssetAmount!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getFeeForCreateContract(registrarNameOrId: Constants.defaultName,
                                              assetId: Constants.defaultAsset,
                                              amount: 0, assetForFee: nil,
                                              byteCode: Constants.counterContractByteCode,
                                              supportedAssetId: nil,
                                              ethAccuracy: false) { (result) in
                switch result {
                case .success(let aFee):
                    fee = aFee
                case .failure(let error):
                    XCTFail("Fee for call contract getting failed \(error)")
                }
                exp.fulfill()
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(fee)
        }
    }
    
    func testGetFeeForCallContract() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetFeeForCallContract")
        let registrarNameOrId = Constants.defaultName
        let assetId = Constants.defaultAsset
        let contratId = Constants.counterContract
        let methodName = Constants.defaultCallContractMethod
        let params: [AbiTypeValueInputModel] = []

        var fee: CallContractFee!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getFeeForCallContractOperation(registrarNameOrId: registrarNameOrId,
                                                     assetId: assetId,
                                                     amount: nil,
                                                     assetForFee: nil,
                                                     contratId: contratId,
                                                     methodName: methodName,
                                                     methodParams: params,
                                                     completion: { (result) in
                switch result {
                case .success(let aFee):
                    fee = aFee
                case .failure(let error):
                    XCTFail("Fee for call contract getting failed \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(fee)
        }
    }
    
    func testGetFeeForCallContractByCode() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetFeeForCallContractByCode")
        let registrarNameOrId = Constants.defaultName
        let assetId = Constants.defaultAsset
        let contratId = Constants.counterContract
        let byteCode = Constants.defaultCallContractBytecode
        
        var fee: CallContractFee!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getFeeForCallContractOperation(registrarNameOrId: registrarNameOrId,
                                                     assetId: assetId,
                                                     amount: nil,
                                                     assetForFee: nil,
                                                     contratId: contratId,
                                                     byteCode: byteCode,
                                                     completion: { (result) in
                switch result {
                case .success(let aFee):
                    fee = aFee
                case .failure(let error):
                    XCTFail("Fee for call contract getting failed \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(fee)
        }
    }
    
    func testGetFeeForCallContractInAnotherAsset() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetFeeForCallContractInAnotherAsset")
        let registrarNameOrId = Constants.defaultName
        let assetId = Constants.defaultAnotherAsset
        let contratId = Constants.counterContract
        let methodName = Constants.defaultCallContractMethod
        let params: [AbiTypeValueInputModel] = []
        
        var fee: CallContractFee!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getFeeForCallContractOperation(registrarNameOrId: registrarNameOrId,
                                                     assetId: assetId,
                                                     amount: nil,
                                                     assetForFee: nil,
                                                     contratId: contratId,
                                                     methodName: methodName,
                                                     methodParams: params,
                                                     completion: { (result) in
                switch result {
                case .success(let aFee):
                    fee = aFee
                case .failure(let error):
                    XCTFail("Fee for call contract getting failed \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(fee)
        }
    }
    
    func testGetFeeForCallContractFailed() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetFeeForCallContractFailed")
        let registrarNameOrId = Constants.defaultName + "someString"
        let assetId = Constants.defaultAsset
        let contratId = Constants.counterContract
        let methodName = Constants.defaultCallContractMethod
        let params: [AbiTypeValueInputModel] = []
        
        var userError: Error!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getFeeForCallContractOperation(registrarNameOrId: registrarNameOrId,
                                                     assetId: assetId,
                                                     amount: nil,
                                                     assetForFee: nil,
                                                     contratId: contratId,
                                                     methodName: methodName,
                                                     methodParams: params,
                                                     completion: { (result) in
                switch result {
                case .success(_):
                    XCTFail("Getting fee for transfer with undefining user must fail")
                case .failure(let error):
                    userError = error
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(userError)
        }
    }
    
    func testTransferWithWIF() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testTransferWithWIF")
        let fromUser = Constants.defaultName
        let wif = Constants.defaultWIF
        let toUser = Constants.defaultToName
        var isSuccess = false
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.sendTransferOperation(fromNameOrId: fromUser,
                                            wif: wif,
                                            toNameOrId: toUser,
                                            amount: 100000000,
                                            asset: Constants.defaultAsset,
                                            assetForFee: nil,
                                            sendCompletion: { (result) in
                switch result {
                case .success:
                    print("Send success")
                case .failure(let error):
                    XCTFail("Transfer must be valid \(error)")
                }
            }, confirmNoticeHandler: { notice in
                switch notice {
                case .success:
                    isSuccess = true
                case .failure(let error):
                    XCTFail("Transfer must be valid \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(isSuccess)
        }
    }
    
    func testTransferWithAssetForFeeWithWIF() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testTransferWithAssetForFeeWithWIF")
        let fromUser = Constants.defaultName
        let wif = Constants.defaultWIF
        let toUser = Constants.defaultToName
        var isSuccess = false
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.sendTransferOperation(fromNameOrId: fromUser,
                                            wif: wif,
                                            toNameOrId: toUser,
                                            amount: 1,
                                            asset: Constants.defaultAsset,
                                            assetForFee: Constants.defaultAnotherAsset,
                                            sendCompletion: { (result) in
                switch result {
                case .success:
                    print("Send success")
                case .failure(let error):
                    XCTFail("Transfer must be valid \(error)")
                }
            }, confirmNoticeHandler: { notice in
                switch notice {
                case .success:
                    isSuccess = true
                case .failure(let error):
                    XCTFail("Transfer must be valid \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(isSuccess)
        }
    }
    
    func testFailedTransferWithWif() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testFailedTransferWithWif")
        let wif = Constants.defaultWIF + "asdf"
        let fromUser = Constants.defaultName
        let toUser = Constants.defaultToName
        var isSuccess = false
        
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.sendTransferOperation(fromNameOrId: fromUser,
                                            wif: wif,
                                            toNameOrId: toUser,
                                            amount: 1,
                                            asset: Constants.defaultAsset,
                                            assetForFee: nil,
                                            sendCompletion: { (result) in
                switch result {
                case .success(_):
                    XCTFail("Transfer cant be valid")
                case .failure(_):
                    isSuccess = false
                }
                exp.fulfill()
            }, confirmNoticeHandler: nil)
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertFalse(isSuccess)
        }
    }
    
    func testGetAssets() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetAssets")
        let assetsIds = [Constants.defaultAsset, Constants.defaultAnotherAsset]
        var assets: [Asset] = []
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getAsset(assetIds: assetsIds, completion: { (result) in
                switch result {
                case .success(let aAssets):
                    assets = aAssets
                case .failure(_):
                    XCTFail("Assets getting fail")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertEqual(assets.count, assetsIds.count)
        }
    }
    
    func testFailedGetAssets() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testFailedGetAssets")
        let assetsIds = ["2.3.0", "2.3.2"]
        var error: ECHOError = ECHOError.undefined

        //act
        echo.start { [unowned self] (result) in
            
            self.echo.getAsset(assetIds: assetsIds, completion: { (result) in
                switch result {
                case .success(_):
                    XCTFail("Assets getting fail")
                case .failure(let aError):
                    error = aError
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { _ in
            XCTAssertEqual(error, ECHOError.identifier(.asset))
        }
    }
    
    func testGetListAssets() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetListAssets")
        let lowerBound = Constants.defaultAssetLowerBound
        let limit = 10
        var assets: [Asset] = []
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.listAssets(lowerBound: lowerBound, limit: limit, completion: { (result) in
                switch result {
                case .success(let aAssets):
                    assets = aAssets
                case .failure(_):
                    XCTFail("List assets getting fail")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(assets.count > 0 && assets.count <= limit)
        }
    }

//    func testCreateAsset() {
//
//        //arrange
//        echo = ECHO(settings: Settings(build: {
//            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
//            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
//            $0.debug = true
//            $0.debug = true
//        }))
//        let exp = expectation(description: "testCreateAsset")
//        var asset = Asset("")
//        asset.symbol = "SHARAEVTEST"
//        asset.precision = 4
//        asset.issuer = Account("1.2.62")
////        asset.setBitsassetOptions(BitassetOptions(feedLifetimeSec: 86400,
////                                                  minimumFeeds: 7,
////                                                  forceSettlementDelaySec: 86400,
////                                                  forceSettlementOffsetPercent: 100,
////                                                  maximumForceSettlementVolume: 2000,
////                                                  shortBackingAsset: Constants.defaultAsset))
//
//        asset.options = AssetOptions(maxSupply: 10000000,
//                                     issuerPermissions: AssetOptionIssuerPermissions.chargeMarketFee.rawValue,
//                                     flags: AssetOptionIssuerPermissions.committeeFedAsset.rawValue,
//                                     coreExchangeRate: Price(base: AssetAmount(amount: 1,
//                                                                               asset: Asset(Constants.defaultAsset)),
//                                                             quote: AssetAmount(amount: 1, asset: Asset("1.3.1"))),
//                                     description: "description")
//        let nameOrId = Constants.defaultName
//        let wif = Constants.defaultWIF
//        var success: Bool!
//
//        //act
//        echo.start { [unowned self] (result) in
//
//            self.echo.createAsset(
//                nameOrId: nameOrId,
//                wif: wif,
//                asset: asset,
//                sendCompletion: { result in
//                    switch result {
//                    case .success:
//                        print("Send asset creation success")
//                    case .failure(let error):
//                        XCTFail("Create asset cant fail \(error)")
//                    }
//                }, confirmNoticeHandler: { notice in
//                    switch notice {
//                    case .failure(let error):
//                        XCTFail("Create asset cant fail \(error)")
//                    case .success:
//                        success = true
//                    }
//                    exp.fulfill()
//                }
//            )
//        }
//
//        //assert
//        waitForExpectations(timeout: Constants.timeout) { error in
//            XCTAssertTrue(success)
//        }
//    }
    
//    func testIssueAsset() {
//
//        echo = ECHO(settings: Settings(build: {
//            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
//            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
//            $0.debug = true
//        }))
//        let exp = expectation(description: "testIssueAsset")
//
//        let nameOrId = Constants.defaultName
//        let wif = Constants.defaultWIF
//        var success: Bool!
//
//        //act
//        echo.start { [unowned self] (result) in
//            self.echo.issueAsset(
//                issuerNameOrId: nameOrId,
//                wif: wif,
//                asset: Constants.defaultAnotherAsset,
//                amount: 10000000,
//                destinationIdOrName: Constants.defaultName,
//                sendCompletion: { result in
//                    switch result {
//                    case .success:
//                        print("Issue asset send success")
//
//                    case .failure(let error):
//                        XCTFail("Issue asset cant fail \(error)")
//                    }
//                }, confirmNoticeHandler: { notice in
//                    switch result {
//                    case .success:
//                        success = true
//
//                    case .failure(let error):
//                        XCTFail("Issue asset cant fail \(error)")
//                    }
//                    exp.fulfill()
//                }
//            )
//        }
//
//        //assert
//        waitForExpectations(timeout: Constants.timeout) { error in
//            XCTAssertTrue(success)
//        }
//    }
    
    func testChangePassword() {

        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testChangePassword")
        let userName = Constants.defaultName
        let wif = Constants.defaultWIF
        let newWIF = Constants.defaultWIF
        var success: Bool!

        //act
        echo.start { [unowned self] (result) in
            self.echo.changeKeys(
                oldWIF: wif,
                newWIF: newWIF,
                name: userName,
                sendCompletion: { result in
                    switch result {
                    case .success:
                        print("Change keys send success")
                    case .failure(let error):
                        XCTFail("Change password cant fail \(error)")
                        exp.fulfill()
                    }
                }, confirmNoticeHandler: { notice in
                    switch notice {
                    case .success:
                        success = true
                    case .failure(let error):
                        XCTFail("Change password cant fail \(error)")
                    }
                    exp.fulfill()
                }
            )
        }

        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(success)
        }
    }
    
    func testGetContractResult() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetContractResult")
        let contractResultId = Constants.evmContractResult
        var contractResult: ContractResultEVM!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getContractResult(contractResultId: contractResultId, completion: { (result) in
                switch result {
                case .success(let res):
                    switch res {
                    case .evm(let result):
                        contractResult = result
                    case .x86(_):
                        XCTFail("Getting result cant be x86")
                    }
                case .failure(let error):
                    XCTFail("Getting result cant fail \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(contractResult)
        }
    }
    
    //TODO: Network issue
//    func testGetx86ContractResult() {
//
//        //arrange
//        echo = ECHO(settings: Settings(build: {
//            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
//            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
//            $0.debug = true
//            $0.debug = true
//        }))
//        let exp = expectation(description: "testGetx86ContractResult")
//        let contractResultId = Constants.x86ContractResult
//        var contractResult: ContractResultx86!
//
//        //act
//        echo.start { [unowned self] (result) in
//            self.echo.getContractResult(contractResultId: contractResultId, completion: { (result) in
//                switch result {
//                case .success(let res):
//                    switch res {
//                    case .evm(_):
//                        XCTFail("Getting result cant be EVM")
//                    case .x86(let result):
//                        contractResult = result
//                    }
//                    exp.fulfill()
//                case .failure(let error):
//                    XCTFail("Getting result cant fail \(error)")
//                }
//            })
//        }
//
//        //assert
//        waitForExpectations(timeout: Constants.timeout) { error in
//            XCTAssertNotNil(contractResult)
//        }
//    }
    
    func testFailGetContractResult() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testFailGetContractResult")
        let contractResultId = "3.17.2"
        var error: ECHOError = ECHOError.undefined

        //act
        echo.start { [unowned self] (result) in
            self.echo.getContractResult(contractResultId: contractResultId, completion: { (result) in
                switch result {
                case .success(_):
                    XCTFail("Getting contract fail")
                case .failure(let aError):
                    error = aError
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { _ in
            XCTAssertNotEqual(error, ECHOError.undefined)
        }
    }
    
    func testGetContractLogs() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetContractLogs")
        let contractId = Constants.logsContract
        let fromBlock = Constants.contractLogsFromBlock
        let toBlock = Constants.contractLogsFromBlock
        var contractLogs: [ContractLogEnum]!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getContractLogs(contractId: contractId,
                                      fromBlock: fromBlock,
                                      toBlock: toBlock,
                                      completion: { (result) in
                
                switch result {
                case .success(let logs):
                    contractLogs = logs
                case .failure(let error):
                    XCTFail("Getting result cant fail \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(contractLogs)
            if contractLogs != nil {
                XCTAssertEqual(contractLogs.count, 2)
            }
        }
    }
    
    func testFailGetContractLogs() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testFailGetContractLogs")
        let contractId = "1.3.1880"
        let fromBlock = Constants.contractLogsFromBlock
        let toBlock = Constants.contractLogsFromBlock + 20
        var error: ECHOError = ECHOError.undefined
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getContractLogs(contractId: contractId, fromBlock: fromBlock, toBlock: toBlock, completion: { (result) in
                
                switch result {
                case .success(_):
                    XCTFail("Getting contract fail")
                case .failure(let aError):
                    error = aError
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { _ in
            XCTAssertNotEqual(error, ECHOError.undefined)
        }
    }
    
    func testGetContracts() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetContracts")
        let legalContractId = Constants.counterContract
        let contractsIDs = [legalContractId]
        var contracts: [ContractInfo] = []

        //act
        echo.start { [unowned self] (result) in
            self.echo.getContracts(contractIds: contractsIDs, completion: { (result) in
                switch result {
                case .success(let res):
                    contracts = res
                case .failure(_):
                    XCTFail("Getting contracts result cant fail")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(contracts.count == 1)
        }
    }
    
    func testFailGetContracts() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testFailGetContracts")
        let illegalContractId = "3.16.1"
        let contractsIDs = [illegalContractId]
        var error: ECHOError = ECHOError.undefined

        //act
        echo.start { [unowned self] (result) in
            self.echo.getContracts(contractIds: contractsIDs, completion: { (result) in
                switch result {
                case .success(_):
                    XCTFail("Getting contract fail")
                case .failure(let aError):
                    error = aError
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { _ in
            XCTAssertNotEqual(error, ECHOError.undefined)
        }
    }
    
    func testGetContract() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetContract")
        let legalContractId = Constants.counterContract
        var contract: ContractStructEVM!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getContract(contractId: legalContractId, completion: { (result) in
                switch result {
                case .success(let res):
                    switch res {
                    case .evm(let contractStruct):
                        contract = contractStruct
                    case .x86(_):
                        XCTFail("Getting contracts result cant be x86 type")
                    }
                case .failure(let error):
                    XCTFail("Getting contracts result cant fail \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(contract)
        }
    }
    
    //TODO: Network issue
//    func testGetx86Contract() {
//
//        //arrange
//        echo = ECHO(settings: Settings(build: {
//            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
//            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
//            $0.debug = true
//            $0.debug = true
//        }))
//        let exp = expectation(description: "testGetx86Contract")
//        let legalContractId = Constants.x86Contract
//        var contract: ContractStructx86!
//
//        //act
//        echo.start { [unowned self] (result) in
//            self.echo.getContract(contractId: legalContractId, completion: { (result) in
//                switch result {
//                case .success(let res):
//                    switch res {
//                    case .evm(_):
//                        XCTFail("Getting contracts result cant be EVM type")
//                    case .x86(let contractStruct):
//                        contract = contractStruct
//                    }
//                    exp.fulfill()
//                case .failure(let error):
//                    XCTFail("Getting contracts result cant fail \(error)")
//                }
//            })
//        }
//
//        //assert
//        waitForExpectations(timeout: Constants.timeout) { error in
//            XCTAssertNotNil(contract)
//        }
//    }
    
    func testFailGetContract() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testFailGetContract")
        let illegalContractId = "3.16.1"
        var error: ECHOError = ECHOError.undefined
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getContract(contractId: illegalContractId, completion: { (result) in
                switch result {
                case .success(_):
                    XCTFail("Getting contract fail")
                case .failure(let aError):
                    error = aError
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { _ in
            XCTAssertEqual(error, ECHOError.identifier(.contract))
        }
    }
    
    func testCreateContract() {

        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testCreateContract")
        let byteCode = Constants.logContractByteCode
        var success = false

        //act
        echo.start { [unowned self] (result) in

            self.echo.createContract(registrarNameOrId: Constants.defaultName,
                                     wif: Constants.defaultWIF,
                                     assetId: Constants.defaultAsset,
                                     amount: nil,
                                     assetForFee: nil,
                                     byteCode: byteCode,
                                     supportedAssetId: nil,
                                     ethAccuracy: false,
                                     parameters: nil,
                                     sendCompletion: { (result) in
             switch result {
                 case .success:
                     print("Send success")
                 case .failure(let error):
                     XCTFail("Create contract must be valid \(error)")
                     exp.fulfill()
                 }
            }, confirmNoticeHandler: { notice in
                 switch notice {
                 case .success:
                     success = true
                 case .failure(let error):
                     XCTFail("Create contract must be valid \(error)")
                 }
                 exp.fulfill()
            })
        }

        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(success)
        }
    }
    
    func testCreateContractByCode() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testCreateContractByCode")
        let byteCode = Constants.counterContractByteCode
        var success = false
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.createContract(registrarNameOrId: Constants.defaultName,
                                     wif: Constants.defaultWIF,
                                     assetId: Constants.defaultAsset,
                                     amount: nil,
                                     assetForFee: nil,
                                     byteCode: byteCode,
                                     supportedAssetId: nil,
                                     ethAccuracy: false,
                                     sendCompletion: { (result) in
                switch result {
                  case .success:
                      print("Send success")
                  case .failure(let error):
                      XCTFail("Create contract must be valid \(error)")
                      exp.fulfill()
                  }
             }, confirmNoticeHandler: { notice in
                  switch notice {
                  case .success:
                      success = true
                  case .failure(let error):
                      XCTFail("Create contract must be valid \(error)")
                  }
                  exp.fulfill()
             })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(success)
        }
    }
    
    func testCreateContractWithWIF() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testCreateContractWithWIF")
        let byteCode = Constants.logContractByteCode
        var success = false
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.createContract(registrarNameOrId: Constants.defaultName,
                                     wif: Constants.defaultWIF,
                                     assetId: Constants.defaultAsset,
                                     amount: nil,
                                     assetForFee: nil,
                                     byteCode: byteCode,
                                     supportedAssetId: nil,
                                     ethAccuracy: false,
                                     parameters: nil,
                                     sendCompletion: { (result) in
              switch result {
                  case .success:
                      print("Send success")
                  case .failure(let error):
                      XCTFail("Create contract must be valid \(error)")
                      exp.fulfill()
                  }
             }, confirmNoticeHandler: { notice in
                  switch notice {
                  case .success:
                      success = true
                  case .failure(let error):
                      XCTFail("Create contract must be valid \(error)")
                  }
                  exp.fulfill()
             })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(success)
        }
    }
    
    func testQueryContract() {

        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testQueryContract")
        let registrarNameOrId = Constants.defaultName
        let assetId = Constants.defaultAsset
        let contratId = Constants.counterContract
        let methodName = Constants.defaultQueryContractMethod
        let params = [AbiTypeValueInputModel]()
        var query: String!

        //act
        echo.start { [unowned self] (result) in
            self.echo.queryContract(registrarNameOrId: registrarNameOrId,
                                    amount: 0,
                                    assetId: assetId,
                                    contratId: contratId,
                                    methodName: methodName,
                                    methodParams: params) { (result) in
                
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
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(query)
        }
    }
    
    func testQueryContractByCode() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testQueryContractByCode")
        let registrarNameOrId = Constants.defaultName
        let assetId = Constants.defaultAsset
        let contratId = Constants.counterContract
        let byteCode = Constants.defaultQueryContractBytecode
        var query: String!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.queryContract(registrarNameOrId: registrarNameOrId,
                                    amount: 0,
                                    assetId: assetId,
                                    contratId: contratId,
                                    byteCode: byteCode) { (result) in
                
                switch result {
                case .success(let res):
                    query = res
                case .failure(let error):
                    XCTFail("Query contract cant fail \(error)")
                }
                exp.fulfill()
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(query)
        }
    }
    
    func testCallContract() {

        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testCallContract")
        let registrarNameOrId = Constants.defaultName
        let wif = Constants.defaultWIF
        let assetId = Constants.defaultAsset
        let contratId = Constants.logsContract
        let methodName = Constants.defaultLogsContractMethod
        let params: [AbiTypeValueInputModel] = [AbiTypeValueInputModel(type: .uint(size: 256), value: "1")]
        var success = false

        //act
        echo.start { [unowned self] (result) in
            
            self.echo.callContract(registrarNameOrId: registrarNameOrId,
                                   wif: wif,
                                   assetId: assetId,
                                   amount: nil,
                                   assetForFee: nil,
                                   contratId: contratId,
                                   methodName: methodName,
                                   methodParams: params,
                                   sendCompletion: { (result) in
            switch result {
                case .success:
                    print("Send success")
                case .failure(let error):
                    XCTFail("Call contract must be valid \(error)")
                    exp.fulfill()
                }
           }, confirmNoticeHandler: { notice in
                switch notice {
                case .success:
                    success = true
                case .failure(let error):
                    XCTFail("Call contract must be valid \(error)")
                }
                exp.fulfill()
           })
        }

        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(success)
        }
    }
    
    func testCallContractByCode() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testCallContractByCode")
        let registrarNameOrId = Constants.defaultName
        let wif = Constants.defaultWIF
        let assetId = Constants.defaultAsset
        let contratId = Constants.counterContract
        let byteCode = Constants.defaultCallContractBytecode
        var success = false
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.callContract(registrarNameOrId: registrarNameOrId,
                                   wif: wif,
                                   assetId: assetId,
                                   amount: nil,
                                   assetForFee: nil,
                                   contratId: contratId,
                                   byteCode: byteCode,
                                   sendCompletion: { (result) in
                switch result {
                    case .success:
                        print("Send success")
                    case .failure(let error):
                        XCTFail("Call contract must be valid \(error)")
                        exp.fulfill()
                    }
            }, confirmNoticeHandler: { notice in
                switch notice {
                case .success:
                    success = true
                case .failure(let error):
                    XCTFail("Call contract must be valid \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(success)
        }
    }
    
    func testCustomGetUser() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testCustomGetUser")
        var account: UserAccount?
        let accountName = Constants.defaultName
        let accountsIds = [accountName]
        
        let operation = CustomGetFullAccountSocketOperation(accountsIds: accountsIds) { (result) in
            
            switch result {
            case .success(let userAccounts):
                account = userAccounts[accountName]
            case .failure(let error):
                XCTFail("Getting account cant fail \(error)")
            }
            exp.fulfill()
        }
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.sendCustomOperation(operation: operation, for: .database)
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertEqual(account?.account.name, accountName)
        }
    }
    
    
    func testCustomGetUserFailed() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testCustomGetUserFailed")
        var account: UserAccount?
        let accountName = Constants.defaultName + "someString"
        let accountsIds = [accountName]
        var errorMessage: String?
        
        let operation = CustomGetFullAccountSocketOperation(accountsIds: accountsIds) { (result) in
            
            switch result {
            case .success(let userAccounts):
                account = userAccounts[accountName]
                if account != nil {
                    XCTFail("Getting new account must fail")
                } else {
                    errorMessage = "Account didn't got"
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
            exp.fulfill()
        }
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.sendCustomOperation(operation: operation, for: .database)
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(errorMessage)
        }
    }
    
    func testGetGlobalProperties() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetGlobalProperties")
        var properties: GlobalProperties?
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getGlobalProperties(completion: { (result) in
                switch result {
                case .success(let globalProperties):
                    properties = globalProperties
                case .failure(let error):
                    XCTFail("Error in getting global properties \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(properties)
        }
    }
    
    func testGetBlock() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetBlock")
        let blockNumber = Constants.defaultBlockNumber
        var block: Block?
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getBlock(blockNumber: blockNumber, completion: { (result) in
                
                switch result {
                case .success(let findedBlock):
                    block = findedBlock
                case .failure(let error):
                    XCTFail("Error in getting block \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(block)
        }
    }
    
    // MARK: ETH
    
//    func testGenerateEthAddress() {
//
//        //arrange
//        echo = ECHO(settings: Settings(build: {
//            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
//            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
//            $0.debug = true
//        }))
//        let exp = expectation(description: "testGenerateEthAddress")
//        var isSuccess = false
//
//        //act
//        echo.start { [unowned self] (result) in
//            self.echo.generateEthAddress(nameOrId: Constants.defaultName,
//                                         wif: Constants.defaultWIF,
//                                         assetForFee: nil,
//                                         sendCompletion: { (result) in
//
//                switch result {
//                case .success:
//                    isSuccess = true
//                case .failure(let error):
//                    XCTFail("Generate eth address must be valid \(error)")
//                }
//            }, confirmNoticeHandler: { (_) in
//                exp.fulfill()
//            })
//        }
//
//        //assert
//        waitForExpectations(timeout: Constants.timeout) { error in
//            XCTAssertTrue(isSuccess)
//        }
//    }

    func testGetEthAddress() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetEthAddress")
        var addresses: EthAddress? = nil
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.getEthAddress(
                nameOrId: Constants.defaultName,
                completion: { (result) in
                switch result {
                case .success(let result):
                    addresses = result
                case .failure(let error):
                    XCTFail("Get eth address must be valid \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(addresses)
        }
    }
    
    func testGetFeeWithdrawEth() {
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetFeeWithdrawEth")
        var fee: AssetAmount!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getFeeForWithdrawEthOperation(nameOrId: Constants.defaultName,
                                                    toEthAddress: Constants.defaultETHAddress,
                                                    amount: 1,
                                                    assetForFee: nil) { (result) in
                switch result {
                case .success(let aFee):
                    fee = aFee
                case .failure(let error):
                    XCTFail("testGetFeeWithdrawEth failed \(error)")
                }
                exp.fulfill()
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(fee)
        }
    }
    
    func testWithdrawEth() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testWithdrawEth")
        var isSuccess = false
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.withdrawEth(nameOrId: Constants.defaultName,
                                  wif: Constants.defaultWIF,
                                  toEthAddress: Constants.defaultETHAddress,
                                  amount: 10000,
                                  assetForFee: nil,
                                  sendCompletion: { (result) in
               switch result {
                   case .success:
                       print("Send success")
                   case .failure(let error):
                       XCTFail("Withdraw must be valid \(error)")
                       exp.fulfill()
                   }
            }, confirmNoticeHandler: { notice in
               switch notice {
               case .success:
                   isSuccess = true
               case .failure(let error):
                   XCTFail("Withdraw must be valid \(error)")
               }
               exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(isSuccess)
        }
    }
    
    func testGetEthAccountDeposits() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetEthAccountDeposits")
        var deposits: [EthDeposit]?
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.getEthAccountDeposits(nameOrId: Constants.defaultName, completion: { (result) in
                
                switch result {
                case .success(let result):
                    deposits = result
                case .failure(let error):
                    XCTFail("testGetAccountDeposits must be valid \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(deposits)
            XCTAssertTrue(deposits?.count != 0)
        }
    }
    
    func testGetEthAccountWithdrawals() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetEthAccountWithdrawals")
        var withdrawals: [EthWithdrawal]?
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.getEthAccountWithdrawals(nameOrId: Constants.defaultName, completion: { (result) in
                
                switch result {
                case .success(let result):
                    withdrawals = result
                case .failure(let error):
                    XCTFail("testGetAccountWithdrawals must be valid \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(withdrawals)
            XCTAssertTrue(withdrawals?.count != 0)
        }
    }
    
    // MARK: BTC
    
//    func testGenerateBtcAddress() {
//
//        //arrange
//        echo = ECHO(settings: Settings(build: {
//            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
//            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
//            $0.debug = true
//        }))
//        let exp = expectation(description: "testGenerateBtcAddress")
//        var isSuccess = false
//
//        //act
//        echo.start { [unowned self] (result) in
//            self.echo.generateBtcAddress(nameOrId: Constants.defaultName,
//                                         wif: Constants.defaultWIF,
//                                         backupAddress: Constants.defaultBTCAddress,
//                                         assetForFee: nil,
//                                         sendCompletion: { (result) in
//
//                switch result {
//                case .success:
//                    isSuccess = true
//                case .failure(let error):
//                    XCTFail("Generate btc address must be valid \(error)")
//                }
//            }, confirmNoticeHandler: { (_) in
//                exp.fulfill()
//            })
//        }
//
//        //assert
//        waitForExpectations(timeout: Constants.timeout) { error in
//            XCTAssertTrue(isSuccess)
//        }
//    }

    func testGetBtcAddress() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetBtcAddress")
        var addresses: BtcAddress? = nil
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.getBtcAddress(nameOrId: Constants.defaultName, completion: { (result) in
                switch result {
                case .success(let result):
                    addresses = result
                case .failure(let error):
                    XCTFail("testGetBtcAddress must be valid \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(addresses)
        }
    }
    
    func testGetBtcAccountDeposits() {
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
            let exp = expectation(description: "testGetBtcAccountDeposits")
            var deposits: [BtcDeposit]?
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.getBtcAccountDeposits(nameOrId: Constants.defaultName, completion: { (result) in
                
                switch result {
                case .success(let result):
                    deposits = result
                case .failure(let error):
                    XCTFail("testGetAccountDeposits must be valid \(error)")
                }
                exp.fulfill()
            })
        }
            
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in

            XCTAssertNotNil(deposits)
            XCTAssertTrue(deposits?.count != 0)
        }
    }
    
    func testGetBtcAccountWithdrawals() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        
        let exp = expectation(description: "testGetBtcAccountWithdrawals")
        var withdrawals: [BtcWithdrawal]?
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.getBtcAccountWithdrawals(nameOrId: Constants.defaultName, completion: { (result) in
                
                switch result {
                case .success(let result):
                    withdrawals = result
                case .failure(let error):
                    XCTFail("testGetAccountWithdrawals must be valid \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(withdrawals)
            XCTAssertTrue(withdrawals?.count != 0)
        }
    }
    
    func testGetFeeWithdrawBtc() {
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetFeeWithdrawBtc")
        var fee: AssetAmount!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getFeeForWithdrawBtcOperation(nameOrId: Constants.defaultName,
                                                    toBtcAddress: Constants.defaultBTCAddress,
                                                    amount: 1,
                                                    assetForFee: nil) { (result) in
                switch result {
                case .success(let aFee):
                    fee = aFee
                case .failure(let error):
                    XCTFail("testGetFeeWithdrawBtc failed \(error)")
                }
                exp.fulfill()
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(fee)
        }
    }
    
    func testWithdrawBtc() {

        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testWithdrawBtc")
        var isSuccess = false
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.withdrawBtc(nameOrId: Constants.defaultName,
                                  wif: Constants.defaultWIF,
                                  toBtcAddress: Constants.defaultBTCAddress,
                                  amount: 200000,
                                  assetForFee: nil,
                                  sendCompletion: { (result) in
                                  
                switch result {
                     case .success:
                         print("Send success")
                     case .failure(let error):
                         XCTFail("Withdraw must be valid \(error)")
                         exp.fulfill()
                     }
            }, confirmNoticeHandler: { notice in
                 switch notice {
                 case .success:
                     isSuccess = true
                 case .failure(let error):
                     XCTFail("Withdraw must be valid \(error)")
                 }
                 exp.fulfill()
            })
        }
                                    
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(isSuccess)
        }
    }

    // MARK: ERC20
    
//    func testRegisterERC20Token() {
//
//        //arrange
//        echo = ECHO(settings: Settings(build: {
//            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
//            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
//            $0.debug = true
//        }))
//        let exp = expectation(description: "testRegisterERC20Token")
//        var isSuccess = false
//
//        //act
//        echo.start { [unowned self] (result) in
//            self.echo.registerERC20Token(nameOrId: Constants.defaultName,
//                                         wif: Constants.defaultWIF,
//                                         tokenAddress: Constants.erc20Token,
//                                         tokenName: Constants.erc20TokenName,
//                                         tokenSymbol: Constants.erc20TokenSymbol,
//                                         tokenDecimals: Constants.erc20TokenDecimals,
//                                         assetForFee: nil,
//                                         sendCompletion: { (result) in
//
//                 switch result {
//                 case .success:
//                     isSuccess = true
//                 case .failure(let error):
//                     XCTFail("testRegisterERC20Token must be valid \(error)")
//                 }
//             }, confirmNoticeHandler: { (_) in
//                 exp.fulfill()
//             })
//        }
//
//        //assert
//        waitForExpectations(timeout: Constants.timeout) { error in
//            XCTAssertTrue(isSuccess)
//        }
//    }
    
    func testNotRegisteredERC20Token() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testNotRegisteredERC20Token")
        var token: ERC20Token? = nil
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getERC20Token(tokenAddress: Constants.erc20TokenNotRegistered) { (result) in
                switch result {
                case .success(let result):
                    token = result
                case .failure(let error):
                    XCTFail("testNotRegisteredERC20Token must be valid \(error)")
                }
                exp.fulfill()
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in

            XCTAssertNil(token)
        }
    }

    func testGetERC20Token() {
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetERC20Token")
        var token: ERC20Token? = nil
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getERC20Token(tokenAddress: Constants.erc20Token) { (result) in
                switch result {
                case .success(let result):
                    token = result
                case .failure(let error):
                    XCTFail("testGetERC20Token must be valid \(error)")
                }
                exp.fulfill()
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(token)
        }
    }
    
    func testGetERC20TokenById() {
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetERC20TokenById")
        var token: ERC20Token? = nil
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getERC20Token(tokenId: Constants.erc20TokenEchoId) { (result) in
                switch result {
                case .success(let result):
                    token = result
                case .failure(let error):
                    XCTFail("testGetERC20Token must be valid \(error)")
                }
                exp.fulfill()
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(token)
        }
    }
    
    func testGetERC20TokenByContractId() {
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetERC20TokenById")
        var token: ERC20Token? = nil
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getERC20Token(contractId: Constants.erc20TokenEchoContract) { (result) in
                switch result {
                case .success(let result):
                    token = result
                case .failure(let error):
                    XCTFail("testGetERC20Token must be valid \(error)")
                }
                exp.fulfill()
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(token)
        }
    }

    func testCheckERC20Token() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testCheckERC20Token")
        var isERC20: Bool!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.checkERC20Token(contractId: Constants.erc20TokenEchoContract) { (result) in
                switch result {
                case .success(let result):
                    isERC20 = result
                case .failure(let error):
                    XCTFail("testCheckERC20Token must be valid \(error)")
                }
                exp.fulfill()
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(isERC20)
        }
    }

    func testGetFeeWithdrawERC20() {
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetFeeWithdrawERC20")
        var fee: AssetAmount!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getFeeForWithdrawERC20Operation(nameOrId: Constants.defaultName,
                                                      toEthAddress: Constants.defaultETHAddress,
                                                      tokenId: Constants.erc20TokenEchoId,
                                                      value: "1",
                                                      assetForFee: nil) { (result) in
                switch result {
                case .success(let aFee):
                    fee = aFee
                case .failure(let error):
                    XCTFail("testGetFeeWithdrawERC20 failed \(error)")
                }
                exp.fulfill()
            }
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(fee)
        }
    }
    
    func testWithdrawERC20() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testWithdrawERC20")
        var isSuccess = false
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.withdrawERC20(nameOrId: Constants.defaultName,
                                    wif: Constants.defaultWIF,
                                    toEthAddress: Constants.defaultETHAddress,
                                    tokenId: Constants.erc20TokenEchoId,
                                    value: "1",
                                    assetForFee: nil,
                                    sendCompletion: { (result) in
                
                switch result {
                     case .success:
                         print("Send success")
                     case .failure(let error):
                         XCTFail("Withdraw must be valid \(error)")
                         exp.fulfill()
                     }
            }, confirmNoticeHandler: { notice in
                 switch notice {
                 case .success:
                     isSuccess = true
                 case .failure(let error):
                     XCTFail("Withdraw must be valid \(error)")
                 }
                 exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: 50) { error in
            XCTAssertTrue(isSuccess)
        }
    }
    
    func testGetERC20AccountDeposits() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetERC20AccountDeposits")
        var deposits: [ERC20Deposit]?
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.getERC20AccountDeposits(nameOrId: Constants.defaultName, completion: { (result) in
                
                switch result {
                case .success(let result):
                    deposits = result
                case .failure(let error):
                    XCTFail("testGetAccountDeposits must be valid \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(deposits)
            XCTAssertTrue(deposits?.count != 0)
        }
    }

    func testGetERC20AccountWithdrawals() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .echo)
            $0.debug = true
        }))
        let exp = expectation(description: "testGetERC20AccountWithdrawals")
        var withdrawals: [ERC20Withdrawal]?
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.getERC20AccountWithdrawals(nameOrId: Constants.defaultName, completion: { (result) in
                
                switch result {
                case .success(let result):
                    withdrawals = result
                case .failure(let error):
                    XCTFail("testGetAccountWithdrawals must be valid \(error)")
                }
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(withdrawals)
            XCTAssertTrue(withdrawals?.count != 0)
        }
    }
}
