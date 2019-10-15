//
//  FullAccountStub.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 22.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

struct FullAccountStub {
    
    let initialJson = """
                        {
                            "account": {
                                "id": "1.2.22",
                                "membership_expiration_date": "1970-01-01T00:00:00",
                                "registrar": "1.2.12",
                                "referrer": "1.2.12",
                                "lifetime_referrer": "1.2.12",
                                "network_fee_percentage": 2000,
                                "lifetime_referrer_fee_percentage": 3000,
                                "referrer_rewards_percentage": 7500,
                                "name": "vsharaev",
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
                                "echorand_key": "fd9370d6384ee109765616b2ec5337b221a53a1fa3f3a076b68fcf774994a914",
                                "options": {
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
                            },
                            "statistics": {
                                "id": "2.6.22",
                                "owner": "1.2.22",
                                "most_recent_op": "2.9.443",
                                "total_ops": 13,
                                "removed_ops": 0,
                                "total_core_in_orders": 0,
                                "lifetime_fees_paid": 8067204,
                                "pending_vested_fees": 90
                            },
                            "registrar_name": "nathan",
                            "referrer_name": "nathan",
                            "lifetime_referrer_name": "nathan",
                            "votes": [],
                            "balances": [
                                {
                                    "id": "2.5.11",
                                    "owner": "1.2.22",
                                    "asset_type": "1.3.0",
                                    "balance": "9992032714"
                                },
                                {
                                    "id": "2.5.17",
                                    "owner": "1.2.22",
                                    "asset_type": "1.3.1",
                                    "balance": 999999980
                                }
                            ],
                            "vesting_balances": [],
                            "limit_orders": [],
                            "call_orders": [],
                            "settle_orders": [],
                            "proposals": [],
                            "assets": [],
                            "withdraws": []
                      }
                """
}
