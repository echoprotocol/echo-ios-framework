//
//  GetAllContractsSocketRequestStub.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 10/04/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

struct GetAllContractsSocketRequestStub: SocketRequestStub {
    
    var operationType = "get_all_contracts"
    
    func createResponce(id: Int) -> String {
        return """
        {"id":\(id),"jsonrpc":"2.0","result":[{"id":"1.16.0","statistics":"2.20.0","destroyed":false,"type":"evm"},{"id":"1.16.1","statistics":"2.20.1","destroyed":false,"type":"evm"},{"id":"1.16.2","statistics":"2.20.2","destroyed":false,"type":"evm"},{"id":"1.16.3","statistics":"2.20.3","destroyed":false,"type":"evm"},{"id":"1.16.4","statistics":"2.20.4","destroyed":false,"type":"evm"},{"id":"1.16.5","statistics":"2.20.5","destroyed":false,"type":"evm"},{"id":"1.16.6","statistics":"2.20.6","destroyed":false,"type":"evm"},{"id":"1.16.7","statistics":"2.20.7","destroyed":false,"type":"evm"},{"id":"1.16.8","statistics":"2.20.8","destroyed":false,"type":"evm"},{"id":"1.16.9","statistics":"2.20.9","destroyed":false,"type":"evm"}]}
        """
    }
}
