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
            {"id":\(id),"jsonrpc":"2.0","result":{"id":"2.1.0","head_block_number":6277,"head_block_id":"000018858a61c2876de94f378d8c4c88c991adc2","time":"2019-05-21T10:49:12","next_maintenance_time":"2019-05-22T00:00:00","last_budget_time":"2019-05-21T05:30:31","committee_budget":0,"accounts_registered_this_interval":30,"recently_missed_count":2493482153,"current_aslot":623378658,"recent_slots_filled":"120766879240563501974102418008481117878","dynamic_flags":0,"last_irreversible_block_num":6262}}
            """
    }
}
