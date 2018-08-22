//
//  JsonEncodingTests.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 22.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class JsonEncodingTests: XCTestCase {
    
    func testAuthorityEncode() {
        
        //arrange
        let stub = AuthorityStub()
        let testAuthorityJson = stub.initialJson
        let authority = testAuthorityJson.data(using: .utf8)
            .flatMap {try? JSONDecoder().decode(Authority.self, from: $0)}!
        
        //act
        let authorityJson: String? = authority.toJSON()
        
        //assert
        XCTAssertEqual(authorityJson, stub.toJSON)
    }
    
}
