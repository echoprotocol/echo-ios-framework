//
//  SubscribeToLogsSocketRequestStub.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 28/03/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

struct SetSubscriberToLogsSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "subscribe_contract_logs"
    
    func createResponce(id: Int) -> String {
        
        return """
        
                {"\(id)":7,"jsonrpc":"2.0","result":[]}
        """
    }
}

struct SubscribeToLogsSocketRequestStubHodler: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [SetSubscriberSocketRequestElementStub(),
                                         SetSubscriberToLogsSocketRequestElementStub()]
}
