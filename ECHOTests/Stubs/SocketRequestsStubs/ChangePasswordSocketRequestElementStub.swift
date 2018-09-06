//
//  ChangePasswordSocketRequestStub.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 05.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct ChangePasswordSocketRequestHodlerStub: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [ChangePasswordAccountSocketRequestElementStub(),
                                        ChangePasswordAssetSocketRequestElementStub(),
                                        ChangePasswordSocketRequestElementStub(),
                                        ChangePasswordBlockSocketRequestElementStub(),
                                        ChangePasswordResultSocketRequestElementStub()]
}

struct ChangePasswordAccountSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "get_full_accounts"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":[[\"dima1\",{\"account\":{\"id\":\"1.2.18\",\"membership_expiration_date\":\"1970-01-01T00:00:00\",\"registrar\":\"1.2.17\",\"referrer\":\"1.2.17\",\"lifetime_referrer\":\"1.2.17\",\"network_fee_percentage\":2000,\"lifetime_referrer_fee_percentage\":3000,\"referrer_rewards_percentage\":0,\"name\":\"dima1\",\"owner\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"ECHO6r8aCcMXqYbV1hCVh9ny7Xx3eXCqiaR1wjPH1Atra4JyLDL9mK\",1]],\"address_auths\":[]},\"active\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9\",1]],\"address_auths\":[]},\"options\":{\"memo_key\":\"ECHO5xiJsHy6r2m4XBJiRHmpMUqJHrNjzw3aJe6KE5gzwFn1mwKUR9\",\"voting_account\":\"1.2.5\",\"num_witness\":0,\"num_committee\":0,\"votes\":[],\"extensions\":[]},\"statistics\":\"2.6.18\",\"whitelisting_accounts\":[],\"blacklisting_accounts\":[],\"whitelisted_accounts\":[],\"blacklisted_accounts\":[],\"owner_special_authority\":[0,{}],\"active_special_authority\":[0,{}],\"top_n_control_flags\":0},\"statistics\":{\"id\":\"2.6.18\",\"owner\":\"1.2.18\",\"most_recent_op\":\"2.9.811\",\"total_ops\":273,\"removed_ops\":0,\"total_core_in_orders\":0,\"lifetime_fees_paid\":289921097,\"pending_fees\":0,\"pending_vested_fees\":0},\"registrar_name\":\"nathan\",\"referrer_name\":\"nathan\",\"lifetime_referrer_name\":\"nathan\",\"votes\":[],\"balances\":[{\"id\":\"2.5.2\",\"owner\":\"1.2.18\",\"asset_type\":\"1.3.0\",\"balance\":1728945},{\"id\":\"2.5.4\",\"owner\":\"1.2.18\",\"asset_type\":\"1.3.1\",\"balance\":10000049},{\"id\":\"2.5.34\",\"owner\":\"1.2.18\",\"asset_type\":\"1.3.18\",\"balance\":100000},{\"id\":\"2.5.32\",\"owner\":\"1.2.18\",\"asset_type\":\"1.3.24\",\"balance\":20000}],\"vesting_balances\":[],\"limit_orders\":[],\"call_orders\":[],\"settle_orders\":[],\"proposals\":[],\"assets\":[\"1.3.2\",\"1.3.3\",\"1.3.4\",\"1.3.5\",\"1.3.6\",\"1.3.7\",\"1.3.8\",\"1.3.9\",\"1.3.10\",\"1.3.11\",\"1.3.12\",\"1.3.13\",\"1.3.14\",\"1.3.15\",\"1.3.16\",\"1.3.17\",\"1.3.18\",\"1.3.19\",\"1.3.20\",\"1.3.21\",\"1.3.25\",\"1.3.26\",\"1.3.27\",\"1.3.28\",\"1.3.29\"],\"withdraws\":[]}]]}"
    }
}

struct ChangePasswordAssetSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "get_required_fees"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":[{\"amount\":2013476,\"asset_id\":\"1.3.0\"}]}"
    }
}

struct ChangePasswordSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "get_chain_id"

    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":\"233ae92c7218173c76b5ffad9487b063933eec714a12e3f2ea48026a45262934\"}"
    }
}

struct ChangePasswordBlockSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "get_dynamic_global_properties"

    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":{\"id\":\"2.1.0\",\"head_block_number\":455103,\"head_block_id\":\"0006f1bff791eaf7b153f8b7aa1f2648fe4886aa\",\"time\":\"2018-09-05T10:39:45\",\"current_witness\":\"1.6.2\",\"next_maintenance_time\":\"2018-09-06T00:00:00\",\"last_budget_time\":\"2018-09-05T00:00:00\",\"witness_budget\":0,\"accounts_registered_this_interval\":0,\"recently_missed_count\":0,\"current_aslot\":5340487,\"recent_slots_filled\":\"340282366920938463463374607431768211455\",\"dynamic_flags\":0,\"last_irreversible_block_num\":455095}}"
    }
}

struct ChangePasswordResultSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "broadcast_transaction_with_callback"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":null}"
    }
}




