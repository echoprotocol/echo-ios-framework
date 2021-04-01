//
//  GetTransactionInBlockStubHolder.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 29.03.21.
//  Copyright © 2021 PixelPlex. All rights reserved.
//

import Foundation

struct GetTransactionInBlockStubHolder: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [GetTransactionInBlockRequestStub()]
}
