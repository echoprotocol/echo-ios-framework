//
//  AccountStub.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 22.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

struct AccountStub {
    let initialJson = """
                    {
                                "id": "1.2.22",
                                "membership_expiration_date": "1970-01-01T00:00:00",
                                "registrar": "1.2.12",
                                "referrer": "1.2.12",
                                "lifetime_referrer": "1.2.12",
                                "network_fee_percentage": 2000,
                                "lifetime_referrer_fee_percentage": 3000,
                                "referrer_rewards_percentage": 7500,
                                "name": "vsharaev",
                                "owner": {
                                    "weight_threshold": 1,
                                    "account_auths": [],
                                    "key_auths": [
                                        [
                                            "ECHO8Fs2D8nVEW3x5knWmNKAtTJdC1Zbw7kkxiG1DX5xoFAb1f9nLH",
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
                                            "ECHO6CNWcfkh4DhtbYtjZgMmwb49noxkPFwCu5pYjtNsK3K6XX6JpV",
                                            1
                                        ]
                                    ],
                                    "address_auths": []
                                },
                                "ed_key": "fd91760140895c694197664baeb5388bc9d9bb70b6ee13d087e0404758708418",
                                "options": {
                                    "memo_key": "ECHO7iMzBkAxXJkKy8vMMZ3JZmXHJ7jBz81rNxy1jkwyYXMNJkfVVY",
                                    "voting_account": "1.2.5",
                                    "delegating_account": "1.2.12",
                                    "num_witness": 0,
                                    "num_committee": 0,
                                    "votes": [],
                                    "extensions": []
                                },
                                "statistics": "2.6.22",
                                "whitelisting_accounts": [],
                                "blacklisting_accounts": [],
                                "whitelisted_accounts": [],
                                "blacklisted_accounts": [],
                                "owner_special_authority": [
                                    0,
                                    {}
                                ],
                                "active_special_authority": [
                                    0,
                                    {}
                                ],
                                "top_n_control_flags": 0
                            }
                """
}
