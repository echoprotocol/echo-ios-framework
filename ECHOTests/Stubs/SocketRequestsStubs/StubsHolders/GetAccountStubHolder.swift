//
//  GetAccountStubHolder.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 11/8/18.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct GetAccountStubHolder: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [GetFullAccountsSocketRequestStub()]
}
