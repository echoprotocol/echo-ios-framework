//
//  AuthorityStub.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 22.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct AuthorityStub {
    let initialJson = """
                    {
                    "weight_threshold": 1,
                    "account_auths": [],
                    "key_auths": [["TEST7okvxowDi4pdvJt1t8ksPZFwaemAcFtP8K7cDPcsVnjDbHa1FW", 1]],
                    "address_auths": []
                    }
                    """
    
    let toJSON = "{\"extensions\":[],\"weight_threshold\":1,\"key_auths\":[[\"TEST7okvxowDi4pdvJt1t8ksPZFwaemAcFtP8K7cDPcsVnjDbHa1FW\",1]],\"account_auths\":[]}"
}
