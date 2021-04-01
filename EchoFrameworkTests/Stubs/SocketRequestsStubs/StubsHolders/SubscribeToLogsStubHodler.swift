//
//  SubscribeToLogsStubHodler.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 28/03/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

struct SubscribeToLogsStubHodler: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [SetSubscribeCallbackSocketRequestStub(),
                                         SubscribeContractLogsSocketRequestStub()]
}
