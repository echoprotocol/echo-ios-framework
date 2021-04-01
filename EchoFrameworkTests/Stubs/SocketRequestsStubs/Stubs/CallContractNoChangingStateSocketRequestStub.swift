//
//  CallContractNoChangingStateSocketRequestStub.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 10/04/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

struct CallContractNoChangingStateSocketRequestStub: SocketRequestStub {
    
    var operationType = "call_contract_no_changing_state"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":\"000000000000000000000000000000000000000000000000000000000000003a\"}"
    }
}
