//
//  GetAccountWithdrawalsStubHolder.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 11/06/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

struct GetAccountWithdrawalsStubHolder: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [GetFullAccountsSocketRequestStub(),
                                         GetAccountWithdrawalsRequestStub()]
}
