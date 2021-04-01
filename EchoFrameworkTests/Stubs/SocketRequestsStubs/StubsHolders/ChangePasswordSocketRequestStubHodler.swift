//
//  ChangePasswordSocketRequestStubHodler.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 05.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct ChangePasswordSocketRequestStubHodler: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [GetFullAccountsSocketRequestStub(),
                                        GetRequiredFeesSocketRequestStub(),
                                        GetChainIdSocketRequestStub(),
                                        GetDynamicGlobalPropertiesSocketRequestStub(),
                                        BroadcastTransactionSocketRequestStub()]
}
