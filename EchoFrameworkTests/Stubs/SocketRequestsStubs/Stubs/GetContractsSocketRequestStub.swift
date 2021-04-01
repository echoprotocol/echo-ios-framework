//
//  GetContractsSocketRequestStub.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 10/04/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

struct GetContractsSocketRequestStub: SocketRequestStub {
    
    var operationType = "get_contracts"
    
    func createResponce(id: Int) -> String {
        return """
        {"id":\(id),"jsonrpc":"2.0","result":[{"id":"1.16.56","statistics":"2.20.36","destroyed":false,"type":"evm"}]}
        """
    }
}
