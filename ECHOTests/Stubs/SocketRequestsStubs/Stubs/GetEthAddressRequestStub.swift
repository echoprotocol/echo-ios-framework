//
//  GetEthAddressRequestStub.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 21/05/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

struct GetEthAddressRequestStub: SocketRequestStub {
    
    var operationType = "get_eth_address"
    
    func createResponce(id: Int) -> String {
        
        return """
        {"id":\(id),"jsonrpc":"2.0","result":{"id":"1.12.11","account":"1.2.48","eth_addr":"2f6ec2244bc1ceef401b0abf9345a0decdfd8d8f","is_approved":true,"approves":["1.2.9","1.2.10","1.2.11","1.2.6"]}}
        """
    }
}
