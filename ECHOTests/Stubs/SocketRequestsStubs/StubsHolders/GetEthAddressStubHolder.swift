//
//  GetEthAddressStubHolder.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 21/05/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

struct GetEthAddressStubHolder: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [GetFullAccountsSocketRequestStub(),
                                         GetEthAddressRequestStub()]
}
