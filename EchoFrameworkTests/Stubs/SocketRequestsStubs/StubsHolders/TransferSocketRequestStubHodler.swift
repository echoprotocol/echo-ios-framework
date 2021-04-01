//
//  TransferSocketRequestStubHodler.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 31.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct TransferSocketRequestStubHodler: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [BroadcastTransactionSocketRequestStub(),
                                         GetDynamicGlobalPropertiesSocketRequestStub(),
                                         GetChainIdSocketRequestStub(),
                                         GetRequiredFeesSocketRequestStub(),
                                         GetFullAccountsSocketRequestStub()]
}

