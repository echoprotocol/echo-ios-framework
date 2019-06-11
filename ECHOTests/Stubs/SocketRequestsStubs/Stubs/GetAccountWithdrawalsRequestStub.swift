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
        {"id":\(id),"jsonrpc":"2.0","result":[{"id":"1.19.8","withdraw_id":8,"account":"1.2.48","eth_addr":"46Ba2677a1c982B329A81f60Cf90fBA2E8CA9fA8","value":1,"is_approved":false,"approves":[]},{"id":"1.19.9","withdraw_id":9,"account":"1.2.48","eth_addr":"46Ba2677a1c982B329A81f60Cf90fBA2E8CA9fA8","value":1,"is_approved":false,"approves":[]},{"id":"1.19.10","withdraw_id":10,"account":"1.2.48","eth_addr":"46Ba2677a1c982B329A81f60Cf90fBA2E8CA9fA8","value":1,"is_approved":false,"approves":[]}]}
        """
    }
}
