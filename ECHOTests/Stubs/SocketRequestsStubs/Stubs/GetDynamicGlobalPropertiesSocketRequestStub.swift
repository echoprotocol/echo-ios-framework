//
//  GetDynamicGlobalPropertiesSocketRequestStub.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 10/04/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

struct GetDynamicGlobalPropertiesSocketRequestStub: SocketRequestStub {
    
    var operationType = "get_dynamic_global_properties"
    
    func createResponce(id: Int) -> String {
        return """
            {"id":\(id),"jsonrpc":"2.0","result":{"id":"2.1.0","head_block_number":1957,"head_block_id":"000007a5ef34b1b29cb31547fce4c4bca29c7763","time":"2019-10-14T16:23:16","next_maintenance_time":"2019-10-15T00:00:00","last_budget_time":"1970-01-01T00:00:00","committee_budget":0,"accounts_registered_this_interval":11,"dynamic_flags":0,"last_irreversible_block_num":1942,"last_rand_quantity":"34ff91788921ff3c4d1f646c0e226026643005f91bd484673c7bf57d573ce99e","extensions":[]}}
            """
    }
}
