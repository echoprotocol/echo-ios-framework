//
//  GetAccountWithdrawalsRequestStub.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 11/06/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

struct GetAccountWithdrawalsRequestStub: SocketRequestStub {
    
    var operationType = "get_account_withdrawals"
    
    func createResponce(id: Int) -> String {
        
        return """
        {"id":\(id),"result":[{"id":"1.15.0","withdraw_id":0,"account":"1.2.34","eth_addr":"46Ba2677a1c982B329A81f60Cf90fBA2E8CA9fA8","value":10000,"fee":4000,"is_approved":false,"is_sent":true,"echo_block_number":16048,"approves":["1.2.7"],"extensions":[]}]}
        """
    }
}
