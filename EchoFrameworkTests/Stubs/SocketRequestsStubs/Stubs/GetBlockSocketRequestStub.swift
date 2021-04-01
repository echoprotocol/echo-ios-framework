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
        {"id":\(id),"jsonrpc":"2.0","result":{"previous":"0000000958711fc4bcb21b7fb0a1186b8e44b203","round":10,"timestamp":"2019-08-15T15:00:34","account":"1.2.10","delegate":"1.2.0","transaction_merkle_root":"0000000000000000000000000000000000000000","vm_root":["56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b42156e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421","0.9a71ff66a2f503e4e96c4e9a2521d6a710f2d373b422332029da170d78fa1a68"],"prev_signatures":[{"_step":4,"_value":0,"_leader":9,"_producer":6,"_delegate":0,"_fallback":0,"_bba_sign":"06ff421646f117611343084c91068825390af1ad49eb4a3d4534666d08adc022e63456a7951f3c0b77748c96b26aa6ef0525844c40e3daa22289ed1ef557a903"},{"_step":4,"_value":0,"_leader":9,"_producer":9,"_delegate":0,"_fallback":0,"_bba_sign":"093dc586585e59fc394302b574a4488ae1e79bd5e35d21ea870e0e20c431ea3365ea94003a843412a65e2356267e678270c46fb4dadea4e8aa31fb0d1872f80d"},{"_step":4,"_value":0,"_leader":9,"_producer":11,"_delegate":0,"_fallback":0,"_bba_sign":"c0fe3fa8fa23b179ecaa7a335e98c51e2fbb8a338caa499d1f6cb8a271fec378023e3358c8b5886ac1861b95e1a25a9b73a53afa262ce557150df85e920c0a07"},{"_step":4,"_value":0,"_leader":9,"_producer":12,"_delegate":0,"_fallback":0,"_bba_sign":"d784f31966ca12017c2e369d6c7385a5ff68964b3eb06f3c3a955114e56196968f2c6c95be1268287fb02a7d436d7785afa2fbc6b0976b6546679b14769ab902"},{"_step":4,"_value":0,"_leader":9,"_producer":10,"_delegate":0,"_fallback":0,"_bba_sign":"a5d45aa849328674d459845fd566485238bc10fff5eeffc65f5f0703ae2974fe2a5d7b8a2d360d13de01c556b27c1d517180c43caf08f7557f735afc8af4ee02"}],"extensions":[],"ed_signature":"6c174acb166a4d9e135a72ee0035418d409160577489cf555ed267a9eab2e5d82fbb401329a16ca323bb875edf0f276aa95660acd53f78e4c3b02808c9e7b802","rand":"a2d89cb53c1657808fbdda09d29f84e02991f0371e127325b179c9222d17a68c","cert":[{"_step":4,"_value":0,"_leader":10,"_producer":7,"_delegate":0,"_fallback":0,"_bba_sign":"cf8ff1d95a7dbf9e18901190138b72ee14cf0d8a2baa97ed7e63dc66ab2bd66aa84404ca9148c0db0247963a293877b40bab65a5e80fa2af305a9c5aefa34d0d"},{"_step":4,"_value":0,"_leader":10,"_producer":6,"_delegate":0,"_fallback":0,"_bba_sign":"83bd458fcb57f9e53c7c896c3b3159747c3b7ee6f33c552575a9f5fab6b8bd05c47cfc4990ccc5e447b0dc28bfbe3b6c7976ec1c7d04c3498fb0ee1462d0c70e"},{"_step":4,"_value":0,"_leader":10,"_producer":10,"_delegate":0,"_fallback":0,"_bba_sign":"85be25dbc9852e3743cb4f6b5a1b42a4a93095213c319f68724f06e33e497ff03f254dfc25e386722d1078903e23399cc86370d0b7d135ec36bd3926663e7608"},{"_step":4,"_value":0,"_leader":10,"_producer":12,"_delegate":0,"_fallback":0,"_bba_sign":"d902fb6e93e955e3e568f5b4bb9720ee67124b1b2ae3f4dd1087391f3206f0f22fc3851272e8827d46896a1956443c0ad5435e9b778e180d73a027b71e8fac06"},{"_step":4,"_value":0,"_leader":10,"_producer":11,"_delegate":0,"_fallback":0,"_bba_sign":"0af7b0507ba0e05c6d824f29fa421b1d62339a7fb5867572d16affec7a25723d49cfab78e78dbabeb25c7a95de9f623a11aa1c89863fbd0c98ab6872aa8e8800"}],"transactions":[]}}
        """
    }
}
