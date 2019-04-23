//
//  GetBlockSocketRequestStub.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 23/04/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

struct GetBlockSocketRequestStub: SocketRequestStub {
    
    var operationType = "get_block"
    
    func createResponce(id: Int) -> String {
        
        return """
        {"id":\(id),"jsonrpc":"2.0","result":{"previous":"0015039108276c787ace0db8108a55eda1d6342a","timestamp":"2019-04-23T13:39:01","witness":"1.6.0","account":"1.2.11","transaction_merkle_root":"0000000000000000000000000000000000000000","vm_root":"383b38861054a7d7b9440587d4d36b361c6d2974350530dac8967ea718b26d00.81f3d767a6e6ab95c84cbb50842d29406ac09ea6e76eb36f1346675754636b84 ","extensions":[],"witness_signature":"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000","ed_signature":"c8d148d59fb5ff48e451d69b2284ab8334947ac51dddc19c197f55b3e17f72cd9406e4e6f6cf9de12ec501ea7e340177b6975e23c9a0b2c0a6ba60c7567e8b01","verifications":[],"round":1377170,"rand":"4145ff2e5c8f4ee79b524006ef4c43f00875512d9c2d651d110f7fd4e0c63bde","cert":{"_rand":"4145ff2e5c8f4ee79b524006ef4c43f00875512d9c2d651d110f7fd4e0c63bde","_block_hash":"00150392cbea8c8d4f907116db09286af3d191ef","_producer":11,"_signatures":[{"_step":4,"_value":0,"_signer":11,"_bba_sign":"d8b88386394ce32d07058b3394de46131e6daf92e55059fae9fb2ba3189ab2e62b42f39b39c8d0720ca3de61ff662316fd6f0bc882455cba46a8f0bd4130450a"},{"_step":4,"_value":0,"_signer":204,"_bba_sign":"a27815bb3fe0b044a0366df224bc1c44f6980f4ed3d72c5882a13821b69cd8414850288e3ab20bebeff9d67437db808f8694b72170fe467fbf6a4b69d176ac05"},{"_step":4,"_value":0,"_signer":205,"_bba_sign":"a27815bb3fe0b044a0366df224bc1c44f6980f4ed3d72c5882a13821b69cd8414850288e3ab20bebeff9d67437db808f8694b72170fe467fbf6a4b69d176ac05"},{"_step":4,"_value":0,"_signer":206,"_bba_sign":"a27815bb3fe0b044a0366df224bc1c44f6980f4ed3d72c5882a13821b69cd8414850288e3ab20bebeff9d67437db808f8694b72170fe467fbf6a4b69d176ac05"},{"_step":4,"_value":0,"_signer":244,"_bba_sign":"a27815bb3fe0b044a0366df224bc1c44f6980f4ed3d72c5882a13821b69cd8414850288e3ab20bebeff9d67437db808f8694b72170fe467fbf6a4b69d176ac05"},{"_step":4,"_value":0,"_signer":208,"_bba_sign":"a27815bb3fe0b044a0366df224bc1c44f6980f4ed3d72c5882a13821b69cd8414850288e3ab20bebeff9d67437db808f8694b72170fe467fbf6a4b69d176ac05"}]},"transactions":[]}}
        """
    }
}
