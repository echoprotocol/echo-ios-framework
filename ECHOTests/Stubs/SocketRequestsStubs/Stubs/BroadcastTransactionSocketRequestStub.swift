//
//  BroadcastTransactionSocketRequestStub.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 10/04/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

struct BroadcastTransactionSocketRequestStub: SocketRequestStub {
    
    var operationType = "broadcast_transaction_with_callback"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":null}"
    }
}
