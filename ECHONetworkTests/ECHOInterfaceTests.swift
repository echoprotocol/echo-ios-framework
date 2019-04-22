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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
            $0.network = ECHONetwork(url: "Fake network url", prefix: .bitshares, echorandPrefix: .det)
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
            $0.network = ECHONetwork(url: "fake url", prefix: ECHONetworkPrefix.bitshares, echorandPrefix: .det)
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

    func testRegisterUser() {

        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory, .registration]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testRegisterUser")
        let userName = Constants.defaultName
        let password = Constants.defaultPass
        var finalResult = false

        //act
        echo.start { [unowned self] (result) in
            self.echo.registerAccount(name: userName, password: password, completion: { (result) in
                switch result {
                case .success(let boolResult):
                    finalResult = boolResult
                case .failure(let error):
                    XCTFail("Getting account cant fail \(error)")
                    exp.fulfill()
                }
            }, noticeHandler: { notice in
                exp.fulfill()
            })
        }

        //assert
        waitForExpectations(timeout: 1000) { error in
            XCTAssertEqual(finalResult, true)
        }
    }
    
    func testRegisterRegisteredUser() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory, .registration]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testRegisterRegisteredUser")
        let userName = Constants.defaultName
        let password = Constants.defaultName
        var errorMessage: String?
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.registerAccount(name: userName, password: password, completion: { (result) in
                switch result {
                case .success(_):
                    XCTFail("Register new account must fail")
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    exp.fulfill()
                }
            }, noticeHandler: nil)
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Getting account cant fail \(error)")
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                    exp.fulfill()
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testGettingAccountHistory")
        let userId = Constants.defaultName
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
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(history?.count ?? 0 > 0)
        }
    }
    
    func testGettingAccountHistoryFailed() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testGettingAccountHistoryFailed")
        let userId = "1.2.1234567"
        let startId = "1.11.0"
        let stopId = "1.11.0"
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
                    exp.fulfill()
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Getting balances cant fail \(error)")
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                    exp.fulfill()
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Reserving checking fail \(error)")
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Reserving checking fail \(error)")
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testIsOwnedBy")
        var owned = false
        let userName = Constants.defaultName
        let password = Constants.defaultPass
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.isOwnedBy(name: userName, password: password, completion: { (result) in
                switch result {
                case .success(_):
                    owned = true
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Reserving checking fail \(error)")
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testIsOwnedByFailed")
        var owned = false
        let userName = Constants.defaultName
        let password = "fake password"
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.isOwnedBy(name: userName, password: password, completion: { (result) in
                switch result {
                case .success(_):
                    owned = true
                    exp.fulfill()
                case .failure(_):
                    owned = false
                    exp.fulfill()
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testIsOwnedByWIF")
        let name = Constants.defaultName
        let password = Constants.defaultPass
        let keysContainer = AddressKeysContainer(login: name, password: password, core: CryptoCoreImp())!
        let wif = keysContainer.activeKeychain.wif()
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
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Fail check is owned by WIF \(error)")
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testIsOwnedByWIFAccountNotCreated")
        let name = Constants.defaultName + "someString"
        let password = Constants.defaultPass
        let keysContainer = AddressKeysContainer(login: name, password: password, core: CryptoCoreImp())!
        let wif = keysContainer.activeKeychain.wif()
        var count = -1
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.isOwnedBy(wif: wif, completion: { (result) in
                switch result {
                case .success(let accounts):
                    count = accounts.count
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Fail check is owned by WIF \(error)")
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testIsOwnedByWIFFailedWIF")
        let name = Constants.defaultName + "someString"
        let password = Constants.defaultPass
        let keysContainer = AddressKeysContainer(login: name, password: password, core: CryptoCoreImp())!
        var wif = keysContainer.activeKeychain.wif()
        wif.removeLast()
        var wasInvalidCredintials = false
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.isOwnedBy(wif: wif, completion: { (result) in
                switch result {
                case .success(_):
                    XCTFail("WIF incorrect, must be error")
                case .failure(let error):
                    switch error {
                    case .invalidCredentials:
                        wasInvalidCredintials = true
                    default:
                        print("Must be wasInvalidCredintials error. but \(error)")
                    }
                    exp.fulfill()
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(wasInvalidCredintials)
        }
    }
    
    func testGetFee() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                                                 asset: Constants.defaultAnotherAsset,
                                                 assetForFee: nil,
                                                 message: nil,
                                                 completion: { (result) in
                switch result {
                case .success(let aFee):
                    fee = aFee
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Fee getting failed \(error)")
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testGetFeeInAnotherAsset")
        let fromUser = Constants.defaultName
        let toUser = Constants.defaultToName
        let assetForFee = Constants.defaultAnotherAsset
        var fee: AssetAmount!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getFeeForTransferOperation(fromNameOrId: fromUser, toNameOrId: toUser, amount: 1, asset: Constants.defaultAsset, assetForFee: assetForFee, message: nil, completion: { (result) in
                switch result {
                case .success(let aFee):
                    fee = aFee
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Fee getting failed \(error)")
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                                                 message: nil,
                                                 completion: { (result) in
                switch result {
                case .success(_):
                    XCTFail("Getting fee for transfer with undefining user must fail")
                case .failure(let error):
                    userError = error
                    exp.fulfill()
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(userError)
        }
    }
    
    func testGetFeeForCallContract() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testGetFeeForCallContract")
        let registrarNameOrId = Constants.defaultName
        let assetId = Constants.defaultAsset
        let contratId = Constants.counterContract
        let methodName = Constants.defaultCallContractMethod
        let params: [AbiTypeValueInputModel] = []

        var fee: AssetAmount!
        
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
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Fee for call contract getting failed \(error)")
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testGetFeeForCallContractByCode")
        let registrarNameOrId = Constants.defaultName
        let assetId = Constants.defaultAsset
        let contratId = Constants.counterContract
        let byteCode = Constants.defaultCallContractBytecode
        
        var fee: AssetAmount!
        
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
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Fee for call contract getting failed \(error)")
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testGetFeeForCallContractInAnotherAsset")
        let registrarNameOrId = Constants.defaultName
        let assetId = Constants.defaultAnotherAsset
        let contratId = Constants.counterContract
        let methodName = Constants.defaultCallContractMethod
        let params: [AbiTypeValueInputModel] = []
        
        var fee: AssetAmount!
        
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
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Fee for call contract getting failed \(error)")
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                    exp.fulfill()
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(userError)
        }
    }
    
    func testTransfer() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testTransfer")
        let fromUser = Constants.defaultName
        let password = Constants.defaultPass
        let toUser = Constants.defaultToName
        var isSuccess = false
        
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.sendTransferOperation(fromNameOrId: fromUser,
                                            passwordOrWif: PassOrWif.password(password),
                                            toNameOrId: toUser,
                                            amount: 1,
                                            asset: Constants.defaultAsset,
                                            assetForFee: nil,
                                            message: "test",
                                            completion: { (result) in
                switch result {
                case .success(let result):
                    isSuccess = result
                case .failure(let error):
                    XCTFail("Transfer must be valid \(error)")
                }
            }, noticeHandler: { notice in
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(isSuccess)
        }
    }
    
    func testTransferWithWIF() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testTransferWithWIF")
        let fromUser = Constants.defaultName
        let password = Constants.defaultPass
        let keysContainer = AddressKeysContainer(login: fromUser, password: password, core: CryptoCoreImp())!
        let wif = keysContainer.activeKeychain.wif()
        let toUser = Constants.defaultToName
        var isSuccess = false
        
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.sendTransferOperation(fromNameOrId: fromUser,
                                            passwordOrWif: PassOrWif.wif(wif),
                                            toNameOrId: toUser,
                                            amount: 1,
                                            asset: Constants.defaultAsset,
                                            assetForFee: nil,
                                            message: "test",
                                            completion: { (result) in
                switch result {
                case .success(let result):
                    isSuccess = result
                case .failure(let error):
                    XCTFail("Transfer must be valid \(error)")
                }
            }, noticeHandler: { notice in
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(isSuccess)
        }
    }
    
    func testTransferWithAssetForFee() {

        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testTransferWithAssetForFee")
        let fromUser = Constants.defaultName
        let password = Constants.defaultPass
        let toUser = Constants.defaultToName
        var isSuccess = false

        //act
        echo.start { [unowned self] (result) in
            self.echo.sendTransferOperation(fromNameOrId: fromUser,
                                            passwordOrWif: PassOrWif.password(password),
                                            toNameOrId: toUser,
                                            amount: 1,
                                            asset: Constants.defaultAsset,
                                            assetForFee: Constants.defaultAnotherAsset,
                                            message: nil,
                                            completion: { (result) in
                switch result {
                case .success(let result):
                    isSuccess = result
                case .failure(let error):
                    print(error)
                    XCTFail("Transfer must be valid")
                }
            }, noticeHandler: { notice in
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testTransferWithAssetForFeeWithWIF")
        let fromUser = Constants.defaultName
        let password = Constants.defaultPass
        let keysContainer = AddressKeysContainer(login: fromUser, password: password, core: CryptoCoreImp())!
        let wif = keysContainer.activeKeychain.wif()
        let toUser = Constants.defaultToName
        var isSuccess = false
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.sendTransferOperation(fromNameOrId: fromUser,
                                            passwordOrWif: PassOrWif.wif(wif),
                                            toNameOrId: toUser,
                                            amount: 1,
                                            asset: Constants.defaultAsset,
                                            assetForFee: Constants.defaultAnotherAsset,
                                            message: nil,
                                            completion: { (result) in
                switch result {
                case .success(let result):
                    isSuccess = result
                case .failure(let error):
                    print(error)
                    XCTFail("Transfer must be valid")
                }
            }, noticeHandler: { notice in
                exp.fulfill()
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(isSuccess)
        }
    }
    
    func testFailedTransfer() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testFailedTransfer")
        let password = Constants.defaultPass + "someString"
        let fromUser = Constants.defaultName
        let toUser = Constants.defaultToName
        var isSuccess = false
        
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.sendTransferOperation(fromNameOrId: fromUser,
                                            passwordOrWif: PassOrWif.password(password),
                                            toNameOrId: toUser,
                                            amount: 1,
                                            asset: Constants.defaultAsset,
                                            assetForFee: nil,
                                            message: "",
                                            completion: { (result) in
                switch result {
                case .success(_):
                    XCTFail("Transfer cant be valid")
                case .failure(_):
                    isSuccess = false
                    exp.fulfill()
                }
            }, noticeHandler: nil)
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertFalse(isSuccess)
        }
    }
    
    func testFailedTransferWithWif() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testFailedTransferWithWif")
        let password = Constants.defaultPass + "someString"
        let fromUser = Constants.defaultName
        let keysContainer = AddressKeysContainer(login: fromUser, password: password, core: CryptoCoreImp())!
        let wif = keysContainer.activeKeychain.wif()
        let toUser = Constants.defaultToName
        var isSuccess = false
        
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.sendTransferOperation(fromNameOrId: fromUser,
                                            passwordOrWif: PassOrWif.wif(wif),
                                            toNameOrId: toUser,
                                            amount: 1,
                                            asset: Constants.defaultAsset,
                                            assetForFee: nil,
                                            message: "",
                                            completion: { (result) in
                                                switch result {
                                                case .success(_):
                                                    XCTFail("Transfer cant be valid")
                                                case .failure(_):
                                                    isSuccess = false
                                                    exp.fulfill()
                                                }
            }, noticeHandler: nil)
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                    exp.fulfill()
                case .failure(_):
                    XCTFail("Assets getting fail")
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                    exp.fulfill()
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                    exp.fulfill()
                case .failure(_):
                    XCTFail("List assets getting fail")
                }
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
//            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
//        }))
//        let exp = expectation(description: "testCreateAsset")
//        var asset = Asset("")
//        asset.symbol = "SHAR"
//        asset.precision = 4
//        asset.issuer = Account("1.2.264")
////        asset.setBitsassetOptions(BitassetOptions(feedLifetimeSec: 86400,
////                                                  minimumFeeds: 7,
////                                                  forceSettlementDelaySec: 86400,
////                                                  forceSettlementOffsetPercent: 100,
////                                                  maximumForceSettlementVolume: 2000,
////                                                  shortBackingAsset: Constants.defaultAsset))
//        asset.predictionMarket = false
//
//        asset.options = AssetOptions(maxSupply: 10000000,
//                                     marketFeePercent: 0,
//                                     maxMarketFee: 0,
//                                     issuerPermissions: AssetOptionIssuerPermissions.committeeFedAsset.rawValue,
//                                     flags: AssetOptionIssuerPermissions.committeeFedAsset.rawValue,
//                                     coreExchangeRate: Price(base: AssetAmount(amount: 1, asset: Asset(Constants.defaultAsset)), quote: AssetAmount(amount: 1, asset: Asset("1.3.1"))),
//                                     description: "description")
//        let nameOrId = Constants.defaultName
//        let password = Constants.defaultPass
//        var success: Bool!
//
//        //act
//        echo.start { [unowned self] (result) in
//
//            self.echo.createAsset(nameOrId: nameOrId, passwordOrWif: PassOrWif.password(password), asset: asset) { (result) in
//
//                switch result {
//                case .success(let isSuccess):
//                    success = isSuccess
//                    exp.fulfill()
//                case .failure(_):
//                    XCTFail("Create asset cant fail")
//                }
//            }
//
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
//            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
//        }))
//        let exp = expectation(description: "testIssueAsset")
//
//        let nameOrId = Constants.defaultName
//        let password = Constants.defaultPass
//        var success: Bool!
//
//        //act
//        echo.start { [unowned self] (result) in
//
//            self.echo.issueAsset(issuerNameOrId: nameOrId,
//                                 passwordOrWif: PassOrWif.password(password),
//                                 asset: Constants.defaultAnotherAsset,
//                                 amount: 10000000,
//                                 destinationIdOrName: Constants.defaultName,
//                                 message: nil, completion: { (result) in
//
//                switch result {
//                case .success(let isSuccess):
//                    success = isSuccess
//                    exp.fulfill()
//                case .failure(_):
//                    XCTFail("Issue asset cant fail")
//                }
//            })
//        }
//
//        //assert
//        waitForExpectations(timeout: Constants.timeout) { error in
//            XCTAssertTrue(success)
//        }
//    }
    
//    func testChangePassword() {
//
//        //arrange
//        echo = ECHO(settings: Settings(build: {
//            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
//            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
//        }))
//        let exp = expectation(description: "testChangePassword")
//        let userName = Constants.defaultName
//        let password = Constants.defaultName
//        let newPassword = Constants.defaultPass
//        var success: Bool!
//
//        //act
//        echo.start { [unowned self] (result) in
//            self.echo.changePassword(old: password, new: newPassword, name: userName, completion: { (result) in
//                switch result {
//                case .success(let isSuccess):
//                    success = isSuccess
//                    exp.fulfill()
//                case .failure(let error):
//                    XCTFail("Change password cant fail \(error)")
//                }
//            })
//        }
//
//        //assert
//        waitForExpectations(timeout: Constants.timeout) { error in
//            XCTAssertTrue(success)
//        }
//    }
    
    func testGetContractResult() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Getting result cant fail \(error)")
                }
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
//            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                    exp.fulfill()
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testGetContractLogs")
        let contractId = Constants.logsContract
        let fromBlock = Constants.contractLogsFromBlock
        let toBlock = Constants.contractLogsToBlock
        var contractLogs: [ContractLog]!
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getContractLogs(contractId: contractId, fromBlock: fromBlock, toBlock: toBlock, completion: { (result) in
                
                switch result {
                case .success(let logs):
                    contractLogs = logs
                    exp.fulfill()
                case .failure(_):
                    XCTFail("Getting result cant fail")
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(contractLogs)
            XCTAssertEqual(contractLogs.count, 2)
        }
    }
    
    func testFailGetContractLogs() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testFailGetContractLogs")
        let contractId = "1.13.1880"
        let fromBlock = Constants.contractLogsFromBlock - 10
        let toBlock = Constants.contractLogsToBlock - 10
        var error: ECHOError = ECHOError.undefined
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getContractLogs(contractId: contractId, fromBlock: fromBlock, toBlock: toBlock, completion: { (result) in
                
                switch result {
                case .success(_):
                    XCTFail("Getting contract fail")
                    exp.fulfill()
                case .failure(let aError):
                    error = aError
                    exp.fulfill()
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { _ in
            XCTAssertNotEqual(error, ECHOError.undefined)
        }
    }
    
    func testGetAllContracts() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testGetAllContracts")
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
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(contracts.count > 0)
        }
    }
    
    func testGetContracts() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                    exp.fulfill()
                case .failure(_):
                    XCTFail("Getting contracts result cant fail")
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                    exp.fulfill()
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Getting contracts result cant fail \(error)")
                }
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
//            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                    exp.fulfill()
                }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testCreateContract")
        let byteCode = Constants.logContractByteCode
        var success = false

        //act
        echo.start { [unowned self] (result) in

            self.echo.createContract(registrarNameOrId: Constants.defaultName,
                                     passwordOrWif: PassOrWif.password(Constants.defaultPass),
                                     assetId: Constants.defaultAsset,
                                     assetForFee: nil,
                                     byteCode: byteCode,
                                     supportedAssetId: nil,
                                     ethAccuracy: false,
                                     parameters: nil,
                                     completion: { (result) in
                switch result {
                case .success(let isSuccess):
                    success = isSuccess
                case .failure(let error):
                    XCTFail("Creating contract cant fail \(error)")
                }
            }, noticeHandler: { (notice) in
                print(notice)
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testCreateContractByCode")
        let byteCode = Constants.counterContractByteCode
        var success = false
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.createContract(registrarNameOrId: Constants.defaultName,
                                     passwordOrWif: PassOrWif.password(Constants.defaultPass),
                                     assetId: Constants.defaultAsset,
                                     assetForFee: nil,
                                     byteCode: byteCode,
                                     supportedAssetId: nil,
                                     ethAccuracy: false,
                                     completion: { (result) in
                switch result {
                case .success(let isSuccess):
                    success = isSuccess
                case .failure(let error):
                    XCTFail("Creating contract cant fail \(error)")
                }
            }, noticeHandler: { (notice) in
                print(notice)
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testCreateContractWithWIF")
        let byteCode = Constants.logContractByteCode
        var success = false
        
        let keysContainer = AddressKeysContainer(login: Constants.defaultName, password: Constants.defaultPass, core: CryptoCoreImp())!
        let wif = keysContainer.activeKeychain.wif()
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.createContract(registrarNameOrId: Constants.defaultName,
                                     passwordOrWif: PassOrWif.wif(wif),
                                     assetId: Constants.defaultAsset,
                                     assetForFee: nil,
                                     byteCode: byteCode,
                                     supportedAssetId: nil,
                                     ethAccuracy: false,
                                     parameters: nil,
                                     completion: { (result) in
                                        switch result {
                                        case .success(let isSuccess):
                                            success = isSuccess
                                        case .failure(let error):
                                            XCTFail("Creating contract cant fail \(error)")
                                        }
            }, noticeHandler: { (notice) in
                print(notice)
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(query)
        }
    }
    
    func testQueryContractByCode() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                                    assetId: assetId,
                                    contratId: contratId,
                                    byteCode: byteCode) { (result) in
                
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
    
    func testCallContract() {

        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testCallContract")
        let registrarNameOrId = Constants.defaultName
        let password = Constants.defaultPass
        let assetId = Constants.defaultAsset
        let contratId = Constants.counterContract
        let methodName = Constants.defaultCallContractMethod
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
                print(notice)
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testCallContractByCode")
        let registrarNameOrId = Constants.defaultName
        let password = Constants.defaultPass
        let assetId = Constants.defaultAsset
        let contratId = Constants.counterContract
        let byteCode = Constants.defaultCallContractBytecode
        var success = false
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.callContract(registrarNameOrId: registrarNameOrId,
                                   passwordOrWif: PassOrWif.password(password),
                                   assetId: assetId,
                                   amount: nil,
                                   assetForFee: nil,
                                   contratId: contratId,
                                   byteCode: byteCode,
                                   completion: { (result) in
                                    
                switch result {
                case .success(let isSuccess):
                    success = isSuccess
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Call contract cant fail \(error)")
                }
            }, noticeHandler: { (notice) in
                print(notice)
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertTrue(success)
        }
    }
    
    func testCallContractWithWIF() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testCallContractWithWIF")
        let registrarNameOrId = Constants.defaultName
        let password = Constants.defaultPass
        let keysContainer = AddressKeysContainer(login: registrarNameOrId, password: password, core: CryptoCoreImp())!
        let wif = keysContainer.activeKeychain.wif()
        let assetId = Constants.defaultAsset
        let contratId = Constants.counterContract
        let methodName = Constants.defaultCallContractMethod
        let params: [AbiTypeValueInputModel] = []
        var success = false
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.callContract(registrarNameOrId: registrarNameOrId,
                                   passwordOrWif: PassOrWif.wif(wif),
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
                print(notice)
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testCustomGetUser")
        var account: UserAccount?
        let accountName = Constants.defaultName
        let accountsIds = [accountName]
        
        let operation = CustomGetFullAccountSocketOperation(accountsIds: accountsIds) { (result) in
            
            switch result {
            case .success(let userAccounts):
                account = userAccounts[accountName]
                exp.fulfill()
            case .failure(let error):
                XCTFail("Getting account cant fail \(error)")
            }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
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
                    exp.fulfill()
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
                exp.fulfill()
            }
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
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testGetGlobalProperties")
        var properties: GlobalProperties?
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getGlobalProperties(completion: { (result) in
                switch result {
                case .success(let globalProperties):
                    properties = globalProperties
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Error in getting global properties \(error)")
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(properties)
        }
    }
    
    func testGetSidechainTransfers() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testGetSidechainTransfers")
        let address = Constants.defaultETHAddress
        var transfers: [SidechainTransfer]?
        
        //act
        echo.start { [unowned self] (result) in
            self.echo.getSidechainTransfers(for: address, completion: { (result) in
                switch result {
                case .success(let sidechainTransfers):
                    transfers = sidechainTransfers
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Error in getting global properties \(error)")
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(transfers)
            XCTAssertTrue(transfers!.count > 0)
        }
    }
    
    func testGetObjectForSidechainTransfer() {
        
        //arrange
        echo = ECHO(settings: Settings(build: {
            $0.apiOptions = [.database, .networkBroadcast, .networkNodes, .accountHistory]
            $0.network = ECHONetwork(url: Constants.nodeUrl, prefix: .echo, echorandPrefix: .det)
        }))
        let exp = expectation(description: "testGetObjectForSidechainTransfer")
        let identifier = Constants.sidechainTransferObject
        var transfer: SidechainTransfer?
        
        //act
        echo.start { [unowned self] (result) in
            
            self.echo.getObjects(type: SidechainTransfer.self, objectsIds: [identifier], completion: { (result) in
                switch result {
                case .success(let sidechainTransfer):
                    transfer = sidechainTransfer.first
                    exp.fulfill()
                case .failure(let error):
                    XCTFail("Error in getting global properties \(error)")
                }
            })
        }
        
        //assert
        waitForExpectations(timeout: Constants.timeout) { error in
            XCTAssertNotNil(transfer)
        }
    }
}
