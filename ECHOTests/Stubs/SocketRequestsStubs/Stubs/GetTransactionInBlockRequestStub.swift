//
//  GetTransactionInBlockRequestStub.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 29.03.21.
//  Copyright © 2021 PixelPlex. All rights reserved.
//

import Foundation

struct GetTransactionInBlockRequestStub: SocketRequestStub {
    
    var operationType = "get_transaction"
    
    func createResponce(id: Int) -> String {
        
        return """
        {"id":\(id),"result":{"ref_block_num":457,"ref_block_prefix":266221538,"expiration":"2021-03-25T13:34:58","operations":[[3,{"fee":{"amount":5095,"asset_id":"1.3.0"},"registrar":"1.2.6","name":"vsharaev2","active":{"weight_threshold":1,"account_auths":[],"key_auths":[["ECHOCuS6J2FDbXQNVLa2a2D7XM1nESghyrSgvmKNLcyKiUN3",1]]},"echorand_key":"ECHOCuS6J2FDbXQNVLa2a2D7XM1nESghyrSgvmKNLcyKiUN3","options":{"delegating_account":"1.2.6","delegate_share":2000,"extensions":[]},"extensions":{}}]],"extensions":[],"signatures":["ba3c0108a02a13fadf974e58af72cc11935b31764fd4efcaae313067ef84211fe1f6814bbc6a9c4357f8cd25cd02308db2430e826af3a2af68a30ae31a2aee02"],"signed_with_echorand_key":true,"operation_results":[[1,"1.2.62"]],"fees_collected":[{"amount":5095,"asset_id":"1.3.0"}]}}
        """
    }
}
