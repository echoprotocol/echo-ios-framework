//
//  CreateContractInfoStubHolder.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 11.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct CreateContractInfoStubHolder: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [GetFullAccountsSocketRequestStub(),
                                         GetRequiredFeesSocketRequestStub(),
                                         GetChainIdSocketRequestStub(),
                                         GetDynamicGlobalPropertiesSocketRequestStub(),
                                         BroadcastTransactionSocketRequestStub()]
}
