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
            {"id":\(id),"result":{"id":"2.1.0","head_block_number":494,"head_block_id":"000001eedee002950c519beb7eb265bf920fff32","time":"2021-03-29T10:14:32","next_maintenance_time":"2021-03-30T00:00:00","last_maintenance_time":"2021-03-29T07:34:47","last_irreversible_block_num":479,"last_block_of_previous_interval":466,"payed_blocks_in_interval":7375,"last_processed_btc_block":1968388,"extensions":[]}}
            """
    }
}
