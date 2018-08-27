//
//  FullHistoryStub.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 23.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

struct FullHistoryStub {
    let initialJson = """
                           [{
                    "id": "1.11.553",
                    "op": [
                    6,
                    {
                    "fee": {
                    "amount": 2013476,
                    "asset_id": "1.3.0"
                    },
                    "account": "1.2.18",
                    "owner": {
                    "weight_threshold": 1,
                    "account_auths": [],
                    "key_auths": [
                    [
                    "ECHO6r8aCcMXqYbV1hCVh9ny7Xx3eXCqiaR1wjPH1Atra4JyLDL9mK",
                    1
                    ]
                    ],
                    "address_auths": []
                    },
                    "active": {
                    "weight_threshold": 1,
                    "account_auths": [],
                    "key_auths": [
                    [
                    "ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9",
                    1
                    ]
                    ],
                    "address_auths": []
                    },
                    "new_options": {
                    "memo_key": "ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9",
                    "voting_account": "1.2.5",
                    "num_witness": 0,
                    "num_committee": 0,
                    "votes": [],
                    "extensions": []
                    },
                    "extensions": {}
                    }
                    ],
                    "result": [
                    0,
                    {}
                    ],
                    "block_num": 88006,
                    "trx_in_block": 0,
                    "op_in_trx": 0,
                    "virtual_op": 598
                    },
                    {
                    "id": "1.11.551",
                    "op": [
                    0,
                    {
                    "fee": {
                    "amount": 20,
                    "asset_id": "1.3.0"
                    },
                    "from": "1.2.18",
                    "to": "1.2.19",
                    "amount": {
                    "amount": 1,
                    "asset_id": "1.3.0"
                    },
                    "memo": {
                    "from": "ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9",
                    "to": "ECHO64LTyVAJSpQGYn1PftVdYpsG2NabcuDUdhH5jFcdZcRF97M8ic",
                    "nonce": 0,
                    "message": "b77b3c909c21d3036f35b3a1b8c82657"
                    },
                    "extensions": []
                    }
                    ],
                    "result": [
                    0,
                    {}
                    ],
                    "block_num": 88002,
                    "trx_in_block": 0,
                    "op_in_trx": 0,
                    "virtual_op": 596
                    },
                    {
                    "id": "1.11.550",
                    "op": [
                    6,
                    {
                    "fee": {
                    "amount": 2013476,
                    "asset_id": "1.3.0"
                    },
                    "account": "1.2.18",
                    "owner": {
                    "weight_threshold": 1,
                    "account_auths": [],
                    "key_auths": [
                    [
                    "ECHO6r8aCcMXqYbV1hCVh9ny7Xx3eXCqiaR1wjPH1Atra4JyLDL9mK",
                    1
                    ]
                    ],
                    "address_auths": []
                    },
                    "active": {
                    "weight_threshold": 1,
                    "account_auths": [],
                    "key_auths": [
                    [
                    "ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9",
                    1
                    ]
                    ],
                    "address_auths": []
                    },
                    "new_options": {
                    "memo_key": "ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9",
                    "voting_account": "1.2.5",
                    "num_witness": 0,
                    "num_committee": 0,
                    "votes": [],
                    "extensions": []
                    },
                    "extensions": {}
                    }
                    ],
                    "result": [
                    0,
                    {}
                    ],
                    "block_num": 87924,
                    "trx_in_block": 0,
                    "op_in_trx": 0,
                    "virtual_op": 595
                    },
                    {
                    "id": "1.11.549",
                    "op": [
                    14,
                    {
                    "fee": {
                    "amount": 2008984,
                    "asset_id": "1.3.0"
                    },
                    "issuer": "1.2.19",
                    "asset_to_issue": {
                    "amount": 1,
                    "asset_id": "1.3.1"
                    },
                    "issue_to_account": "1.2.18",
                    "memo": {
                    "from": "ECHO64LTyVAJSpQGYn1PftVdYpsG2NabcuDUdhH5jFcdZcRF97M8ic",
                    "to": "ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9",
                    "nonce": 0,
                    "message": "557261e1f993de02cd6f23a92c3739d4"
                    },
                    "extensions": []
                    }
                    ],
                    "result": [
                    0,
                    {}
                    ],
                    "block_num": 87876,
                    "trx_in_block": 0,
                    "op_in_trx": 0,
                    "virtual_op": 594
                    },
                    {
                    "id": "1.11.548",
                    "op": [
                    6,
                    {
                    "fee": {
                    "amount": 2013476,
                    "asset_id": "1.3.0"
                    },
                    "account": "1.2.18",
                    "owner": {
                    "weight_threshold": 1,
                    "account_auths": [],
                    "key_auths": [
                    [
                    "ECHO6r8aCcMXqYbV1hCVh9ny7Xx3eXCqiaR1wjPH1Atra4JyLDL9mK",
                    1
                    ]
                    ],
                    "address_auths": []
                    },
                    "active": {
                    "weight_threshold": 1,
                    "account_auths": [],
                    "key_auths": [
                    [
                    "ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9",
                    1
                    ]
                    ],
                    "address_auths": []
                    },
                    "new_options": {
                    "memo_key": "ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9",
                    "voting_account": "1.2.5",
                    "num_witness": 0,
                    "num_committee": 0,
                    "votes": [],
                    "extensions": []
                    },
                    "extensions": {}
                    }
                    ],
                    "result": [
                    0,
                    {}
                    ],
                    "block_num": 87875,
                    "trx_in_block": 1,
                    "op_in_trx": 0,
                    "virtual_op": 593
                    },
                    {
                    "id": "1.11.547",
                    "op": [
                    14,
                    {
                    "fee": {
                    "amount": 2008984,
                    "asset_id": "1.3.0"
                    },
                    "issuer": "1.2.19",
                    "asset_to_issue": {
                    "amount": 1,
                    "asset_id": "1.3.1"
                    },
                    "issue_to_account": "1.2.18",
                    "memo": {
                    "from": "ECHO64LTyVAJSpQGYn1PftVdYpsG2NabcuDUdhH5jFcdZcRF97M8ic",
                    "to": "ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9",
                    "nonce": 0,
                    "message": "557261e1f993de02cd6f23a92c3739d4"
                    },
                    "extensions": []
                            }
                    ],
                    "result": [
                    0,
                    {}
                    ],
                    "block_num": 87875,
                    "trx_in_block": 0,
                    "op_in_trx": 0,
                    "virtual_op": 592
                    },
                    {
                    "id": "1.11.546",
                    "op": [
                    6,
                    {
                    "fee": {
                    "amount": 2013476,
                    "asset_id": "1.3.0"
                    },
                    "account": "1.2.18",
                    "owner": {
                    "weight_threshold": 1,
                    "account_auths": [],
                    "key_auths": [
                    [
                    "ECHO6r8aCcMXqYbV1hCVh9ny7Xx3eXCqiaR1wjPH1Atra4JyLDL9mK",
                    1
                    ]
                    ],
                    "address_auths": []
                    },
                    "active": {
                    "weight_threshold": 1,
                    "account_auths": [],
                    "key_auths": [
                      [
                    "ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9",
                    1
                    ]
                    ],
                    "address_auths": []
                    },
                    "new_options": {
                    "memo_key": "ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9",
                    "voting_account": "1.2.5",
                    "num_witness": 0,
                    "num_committee": 0,
                    "votes": [],
                    "extensions": []
                    },
                    "extensions": {}
                            }
                    ],
                    "result": [
                    0,
                    {}
                    ],
                    "block_num": 87874,
                    "trx_in_block": 1,
                    "op_in_trx": 0,
                    "virtual_op": 591
                    },
                    {
                    "id": "1.11.544",
                    "op": [
                    6,
                    {
                    "fee": {
                    "amount": 2013476,
                    "asset_id": "1.3.0"
                    },
                    "account": "1.2.18",
                    "owner": {
                    "weight_threshold": 1,
                    "account_auths": [],
                    "key_auths": [
                    [
                    "ECHO6r8aCcMXqYbV1hCVh9ny7Xx3eXCqiaR1wjPH1Atra4JyLDL9mK",
                    1
                    ]
                    ],
                    "address_auths": []
                    },
                    "active": {
                    "weight_threshold": 1,
                    "account_auths": [],
                    "key_auths": [
                    [
                    "ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9",
                    1
                    ]
                    ],
                    "address_auths": []
                    },
                    "new_options": {
                    "memo_key": "ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9",
                    "voting_account": "1.2.5",
                    "num_witness": 0,
                    "num_committee": 0,
                    "votes": [],
                    "extensions": []
                    },
                    "extensions": {}
                    }
                    ],
                    "result": [
                    0,
                    {}
                    ],
                    "block_num": 87873,
                    "trx_in_block": 0,
                    "op_in_trx": 0,
                    "virtual_op": 589
                    },
                    {
                    "id": "1.11.543",
                    "op": [
                    6,
                    {
                    "fee": {
                    "amount": 2013476,
                    "asset_id": "1.3.0"
                    },
                    "account": "1.2.18",
                    "owner": {
                    "weight_threshold": 1,
                    "account_auths": [],
                    "key_auths": [
                    [
                    "ECHO6r8aCcMXqYbV1hCVh9ny7Xx3eXCqiaR1wjPH1Atra4JyLDL9mK",
                    1
                    ]
                    ],
                    "address_auths": []
                    },
                    "active": {
                    "weight_threshold": 1,
                    "account_auths": [],
                    "key_auths": [
                    [
                    "ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9",
                    1
                    ]
                    ],
                    "address_auths": []
                    },
                    "new_options": {
                    "memo_key": "ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9",
                    "voting_account": "1.2.5",
                    "num_witness": 0,
                    "num_committee": 0,
                    "votes": [],
                    "extensions": []
                    },
                    "extensions": {}
                    }
                    ],
                    "result": [
                    0,
                    {}
                    ],
                    "block_num": 87872,
                    "trx_in_block": 0,
                    "op_in_trx": 0,
                    "virtual_op": 588
                    },
                    {
                    "id": "1.11.542",
                    "op": [
                    0,
                    {
                    "fee": {
                    "amount": 20,
                    "asset_id": "1.3.0"
                    },
                    "from": "1.2.18",
                    "to": "1.2.19",
                    "amount": {
                    "amount": 1,
                    "asset_id": "1.3.0"
                    },
                    "memo": {
                    "from": "ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9",
                    "to": "ECHO64LTyVAJSpQGYn1PftVdYpsG2NabcuDUdhH5jFcdZcRF97M8ic",
                    "nonce": 0,
                    "message": "b77b3c909c21d3036f35b3a1b8c82657"
                    },
                    "extensions": []
                    }
                    ],
                    "result": [
                    0,
                    {}
                    ],
                    "block_num": 87869,
                    "trx_in_block": 0,
                    "op_in_trx": 0,
                    "virtual_op": 587
                    }]
                    """
}
