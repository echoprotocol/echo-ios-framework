//
//  RevealAPISocketStubsHolder.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 10/04/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

struct RevealAPISocketStubsHolder: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [LoginRevealSocketRequestStub(),
                                         HistoryAPIRevealSocketRequestStub(),
                                         DatabaseAPIRevealSocketRequestStub(),
                                         NetworkBroadcastAPIRevealSocketRequestStub(),
                                         NetworkNodesAPIRevealSocketRequestStub(),
                                         CryptoAPIRevealSocketRequestStub(),
                                         RegistrationAPIRevealSocketRequestStub()]
}
