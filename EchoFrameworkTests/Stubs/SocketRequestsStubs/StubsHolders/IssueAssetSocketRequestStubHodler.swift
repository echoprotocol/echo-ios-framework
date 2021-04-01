//
//  IssueAssetSocketRequestStubHodler.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 06.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct IssueAssetSocketRequestStubHodler: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [BroadcastTransactionSocketRequestStub(),
                                         GetDynamicGlobalPropertiesSocketRequestStub(),
                                         GetChainIdSocketRequestStub(),
                                         GetRequiredFeesSocketRequestStub(),
                                         GetFullAccountsSocketRequestStub()]
}
