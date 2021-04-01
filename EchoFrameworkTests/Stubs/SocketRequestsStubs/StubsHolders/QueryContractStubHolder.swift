//
//  QueryContractInfoStubs.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 14.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct QueryContractStubHolder: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [GetFullAccountsSocketRequestStub(),
                                         CallContractNoChangingStateSocketRequestStub()]
}
