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
            {"id":\(id),"result":{"id":"2.1.0","head_block_number":123,"head_block_id":"0000007ba644bc63a87141e730e062e98763b6b3","time":"2020-09-04T10:57:15","next_maintenance_time":"2020-09-05T00:00:00","last_budget_time":"1970-01-01T00:00:00","committee_budget":0,"dynamic_flags":0,"last_irreversible_block_num":108,"last_block_of_previous_interval":78,"extensions":[]}}
            """
    }
}
