//
//  JsonDecodingTests.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 21.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class JsonDecodingTests: XCTestCase {
    
    func testFullAccountDecode() {
        
        //arrange
        let testFullAccountJson = FullAccountStub().initialJson
        //act
        let object = testFullAccountJson.data(using: .utf8)
            .flatMap {try? JSONDecoder().decode(UserAccount.self, from: $0)}
        
        //assert
        XCTAssertNotNil(object)
    }
    
    func testAccountBalanceDecode() {
        
        //arrange
        let testAccountBalanceJson = AccountBalanceStub().initialJson
        //act
        let object = testAccountBalanceJson.data(using: .utf8)
            .flatMap {try? JSONDecoder().decode(AccountBalance.self, from: $0)}
        
        //assert
        XCTAssertNotNil(object)
    }
    
    func testOptionsDecode() {
        
        //arrange
        let testOptionJson = OptionsStub().initialJson
        //act
        let object = testOptionJson.data(using: .utf8)
            .flatMap {try? JSONDecoder().decode(Options.self, from: $0)}
        
        //assert
        XCTAssertNotNil(object)
    }
    
    func testAuthorityDecode() {
        
        //arrange
        let testAuthorityJson = AuthorityStub().initialJson
        //act
        let object = testAuthorityJson.data(using: .utf8)
            .flatMap {try? JSONDecoder().decode(Authority.self, from: $0)}
        
        //assert
        XCTAssertNotNil(object)
    }
    
    func testStatisticsDecode() {
        
        //arrange
        let testStatisticsJson = StatisticStub().initialJson
        //act
        let object = testStatisticsJson.data(using: .utf8)
            .flatMap {try? JSONDecoder().decode(Statistics.self, from: $0)}
        
        //assert
        XCTAssertNotNil(object)
    }
    
    func testAccountDecode() {
        
        //arrange
        let testAccountJson = AccountStub().initialJson
        //act
        let object = testAccountJson.data(using: .utf8)
            .flatMap {try? JSONDecoder().decode(Account.self, from: $0)}
        
        //assert
        XCTAssertNotNil(object)
    }
    
    func testHistoryDecode() {
        
        //arrange
        let testAccountJson = FullHistoryStub().initialJson
        //act
        let object = testAccountJson.data(using: .utf8)
            .flatMap {try? JSONDecoder().decode([HistoryItem].self, from: $0)}
        
        //assert
        XCTAssertNotNil(object)
    }
}
