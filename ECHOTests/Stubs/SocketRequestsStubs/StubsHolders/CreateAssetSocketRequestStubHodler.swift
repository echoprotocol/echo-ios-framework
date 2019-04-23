//
//  CreateAssetSocketRequestStubHodler.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 06.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct CreateAssetSocketRequestStubHodler: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [GetFullAccountsSocketRequestStub(),
                                         GetChainIdSocketRequestStub(),
                                         GetDynamicGlobalPropertiesSocketRequestStub(),
                                         GetRequiredFeesSocketRequestStub(),
                                         BroadcastTransactionSocketRequestStub()]
}
