//
//  GetContractInfoStubs.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 10.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct GetContractInfoStubHodler: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [GetContractSocketRequestStub(),
                                         GetContractsSocketRequestStub(),
                                         GetContractResultSocketRequestStub()]
}
