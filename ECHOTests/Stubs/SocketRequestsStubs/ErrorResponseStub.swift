//
//  ErrorResponseStub.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 19.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct ErrorResponseStub {
    
    static func getError(id: String, request: String) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"error\":{\"code\":1,\"message\":\(request),\"data\":{}}}"
    }
}
