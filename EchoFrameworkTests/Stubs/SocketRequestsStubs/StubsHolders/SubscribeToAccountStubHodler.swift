//
//  SubscribeToAccountStubHodler.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 11/6/18.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct SubscribeToAccountStubHodler: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [SetSubscribeCallbackSocketRequestStub(),
                                         GetFullAccountsByIdSocketRequestStub()]
}
