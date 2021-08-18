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
        {"id":\(id),"result":[{"id":"1.14.3","deposit_id":4,"account":"1.2.34","value":49793336,"is_sent":true,"echo_block_number":15927,"transaction_hash":"621930706d797d6f695ffc24d22ad0b0bf52bda3c769bc88bbae32d59fb539ab","extensions":[]}]}
        """
    }
}
