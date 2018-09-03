//
//  TransferSocketRequestStub.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 31.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct TransferAccountsSocketRequestStub {
    static let request = "{\"id\":7,\"method\":\"call\",\"params\":[2,\"get_full_accounts\",[[\"nikita1994\",\"dima1\"],false]]}"
    static let response = "{\"id\":7,\"jsonrpc\":\"2.0\",\"result\":[[\"dima1\",{\"account\":{\"id\":\"1.2.18\",\"membership_expiration_date\":\"1970-01-01T00:00:00\",\"registrar\":\"1.2.17\",\"referrer\":\"1.2.17\",\"lifetime_referrer\":\"1.2.17\",\"network_fee_percentage\":2000,\"lifetime_referrer_fee_percentage\":3000,\"referrer_rewards_percentage\":0,\"name\":\"dima1\",\"owner\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"ECHO6r8aCcMXqYbV1hCVh9ny7Xx3eXCqiaR1wjPH1Atra4JyLDL9mK\",1]],\"address_auths\":[]},\"active\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9\",1]],\"address_auths\":[]},\"options\":{\"memo_key\":\"ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9\",\"voting_account\":\"1.2.5\",\"num_witness\":0,\"num_committee\":0,\"votes\":[],\"extensions\":[]},\"statistics\":\"2.6.18\",\"whitelisting_accounts\":[],\"blacklisting_accounts\":[],\"whitelisted_accounts\":[],\"blacklisted_accounts\":[],\"owner_special_authority\":[0,{}],\"active_special_authority\":[0,{}],\"top_n_control_flags\":0},\"statistics\":{\"id\":\"2.6.18\",\"owner\":\"1.2.18\",\"most_recent_op\":\"2.9.53941\",\"total_ops\":331,\"removed_ops\":0,\"total_core_in_orders\":0,\"lifetime_fees_paid\":322136993,\"pending_fees\":0,\"pending_vested_fees\":0},\"registrar_name\":\"nathan\",\"referrer_name\":\"nathan\",\"lifetime_referrer_name\":\"nathan\",\"votes\":[],\"balances\":[{\"id\":\"2.5.2\",\"owner\":\"1.2.18\",\"asset_type\":\"1.3.0\",\"balance\":68613036},{\"id\":\"2.5.4\",\"owner\":\"1.2.18\",\"asset_type\":\"1.3.1\",\"balance\":10000054},{\"id\":\"2.5.34\",\"owner\":\"1.2.18\",\"asset_type\":\"1.3.18\",\"balance\":100000},{\"id\":\"2.5.32\",\"owner\":\"1.2.18\",\"asset_type\":\"1.3.24\",\"balance\":20000}],\"vesting_balances\":[],\"limit_orders\":[],\"call_orders\":[],\"settle_orders\":[],\"proposals\":[],\"assets\":[\"1.3.2\",\"1.3.3\",\"1.3.4\",\"1.3.5\",\"1.3.6\",\"1.3.7\",\"1.3.8\",\"1.3.9\",\"1.3.10\",\"1.3.11\",\"1.3.12\",\"1.3.13\",\"1.3.14\",\"1.3.15\",\"1.3.16\",\"1.3.17\",\"1.3.18\",\"1.3.19\",\"1.3.20\",\"1.3.21\",\"1.3.25\",\"1.3.26\",\"1.3.27\",\"1.3.28\",\"1.3.29\"],\"withdraws\":[]}],[\"nikita1994\",{\"account\":{\"id\":\"1.2.163\",\"membership_expiration_date\":\"1970-01-01T00:00:00\",\"registrar\":\"1.2.17\",\"referrer\":\"1.2.17\",\"lifetime_referrer\":\"1.2.17\",\"network_fee_percentage\":2000,\"lifetime_referrer_fee_percentage\":3000,\"referrer_rewards_percentage\":0,\"name\":\"nikita1994\",\"owner\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"ECHO5CavH12DSGiSgikSMqrobJrb1HhQiAn7vquFMhHwXVbH92dUC8\",1]],\"address_auths\":[]},\"active\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"ECHO5yj4S9KjQP9FGQRRQvU9mWELBNUdoXMvsuKtXmzZUAjhxfriT5\",1]],\"address_auths\":[]},\"options\":{\"memo_key\":\"ECHO8CdXYuB1Nt3G1xsg9a2jtHEgEcvyrkw4uHchSRpg4hwrcoT4uB\",\"voting_account\":\"1.2.5\",\"num_witness\":0,\"num_committee\":0,\"votes\":[],\"extensions\":[]},\"statistics\":\"2.6.163\",\"whitelisting_accounts\":[],\"blacklisting_accounts\":[],\"whitelisted_accounts\":[],\"blacklisted_accounts\":[],\"owner_special_authority\":[0,{}],\"active_special_authority\":[0,{}],\"top_n_control_flags\":0},\"statistics\":{\"id\":\"2.6.163\",\"owner\":\"1.2.163\",\"most_recent_op\":\"2.9.53942\",\"total_ops\":36,\"removed_ops\":0,\"total_core_in_orders\":0,\"lifetime_fees_paid\":26005771,\"pending_fees\":0,\"pending_vested_fees\":20},\"registrar_name\":\"nathan\",\"referrer_name\":\"nathan\",\"lifetime_referrer_name\":\"nathan\",\"votes\":[],\"balances\":[{\"id\":\"2.5.206\",\"owner\":\"1.2.163\",\"asset_type\":\"1.3.0\",\"balance\":69650458}],\"vesting_balances\":[],\"limit_orders\":[],\"call_orders\":[],\"settle_orders\":[],\"proposals\":[],\"assets\":[],\"withdraws\":[]}]]}"
}

struct TransferRequredFeeSocketRequestStub {
    static let request = "{\"id\":8,\"method\":\"call\",\"params\":[2,\"get_required_fees\",[[[0,{\"from\":\"1.2.163\",\"extensions\":[],\"amount\":{\"asset_id\":\"1.3.0\",\"amount\":1},\"fee\":{\"asset_id\":\"1.3.0\",\"amount\":0},\"to\":\"1.2.18\"}]],\"1.3.0\"]]}"
    static let response = "{\"id\":8,\"jsonrpc\":\"2.0\",\"result\":[{\"amount\":20,\"asset_id\":\"1.3.0\"}]}"
}

struct TransferChainIdSocketRequestStub {
    static let request = "{\"id\":9,\"method\":\"call\",\"params\":[2,\"get_chain_id\",[]]}"
    static let response = "{\"id\":9,\"jsonrpc\":\"2.0\",\"result\":\"233ae92c7218173c76b5ffad9487b063933eec714a12e3f2ea48026a45262934\"}"
}

struct TransferGlobalPropertiesSocketRequestStub {
    static let request = "{\"id\":10,\"method\":\"call\",\"params\":[2,\"get_dynamic_global_properties\",[]]}"
    static let response = "{\"id\":10,\"jsonrpc\":\"2.0\",\"result\":{\"id\":\"2.1.0\",\"head_block_number\":366882,\"head_block_id\":\"0005992255c54a880c224926c225536ee557e99c\",\"time\":\"2018-08-31T08:01:05\",\"current_witness\":\"1.6.9\",\"next_maintenance_time\":\"2018-09-01T00:00:00\",\"last_budget_time\":\"2018-08-31T00:00:00\",\"witness_budget\":0,\"accounts_registered_this_interval\":0,\"recently_missed_count\":0,\"current_aslot\":5252198,\"recent_slots_filled\":\"340282366920938463463374607431768211455\",\"dynamic_flags\":0,\"last_irreversible_block_num\":366869}}"
}

struct TransferResultSocketRequestStub {
    static let request = "{\"id\":11,\"method\":\"call\",\"params\":[3,\"broadcast_transaction_with_callback\",[11,{\"extensions\":[],\"operations\":[[0,{\"from\":\"1.2.163\",\"extensions\":[],\"amount\":{\"asset_id\":\"1.3.0\",\"amount\":1},\"fee\":{\"asset_id\":\"1.3.0\",\"amount\":20},\"to\":\"1.2.18\"}]],\"ref_block_prefix\":2286601557,\"expiration\":\"2018-08-31T08:01:45\",\"ref_block_num\":39202,\"signatures\":[\"1f4a8b44015926a337801bd0ea3f1a20bd39997b629007cca8f7d1cb78a0acbd0d0be0bfbeb480717b101e61566a9a6a4cedcff407c742134c77d54c1096213727\"]}]]}"
    static let response = "{\"id\":11,\"jsonrpc\":\"2.0\",\"result\":null}"
}



