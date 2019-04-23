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
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":{\"id\":\"2.1.0\",\"head_block_number\":366882,\"head_block_id\":\"0005992255c54a880c224926c225536ee557e99c\",\"time\":\"2018-08-31T08:01:05\",\"current_witness\":\"1.6.9\",\"next_maintenance_time\":\"2018-09-01T00:00:00\",\"last_budget_time\":\"2018-08-31T00:00:00\",\"witness_budget\":0,\"accounts_registered_this_interval\":0,\"recently_missed_count\":0,\"current_aslot\":5252198,\"recent_slots_filled\":\"340282366920938463463374607431768211455\",\"dynamic_flags\":0,\"last_irreversible_block_num\":366869}}"
    }
}
