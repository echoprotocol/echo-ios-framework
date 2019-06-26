//
//  GetAccountDepositsRequestStub.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 11/06/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

struct GetAccountDepositsRequestStub: SocketRequestStub {
    
    var operationType = "get_account_deposits"
    
    func createResponce(id: Int) -> String {
        
        return """
        {"id":\(id),"jsonrpc":"2.0","result":[{"id":"1.18.1","deposit_id":2,"account":"1.2.48","value":199800,"is_approved":true,"approves":[]}]}
        """
    }
}
