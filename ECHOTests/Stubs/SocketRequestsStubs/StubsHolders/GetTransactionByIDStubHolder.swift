//
//  GetTransactionByIDStubHolder.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 29.03.21.
//  Copyright © 2021 PixelPlex. All rights reserved.
//

import Foundation

struct GetTransactionByIDStubHolder: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [GetTransactionByIDRequestStub()]
}
