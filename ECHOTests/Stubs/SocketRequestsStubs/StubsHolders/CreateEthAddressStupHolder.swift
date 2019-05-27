//
//  CreateEthAddressStubHolder.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 21/05/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

struct CreateEthAddressStubHolder: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [BroadcastTransactionSocketRequestStub(),
                                         GetDynamicGlobalPropertiesSocketRequestStub(),
                                         GetChainIdSocketRequestStub(),
                                         GetRequiredFeesSocketRequestStub(),
                                         GetFullAccountsSocketRequestStub()]
}
