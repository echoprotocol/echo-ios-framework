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
        return """
                {"id":\(id),"jsonrpc":"2.0","result":[["vsharaev",{"account":{"id":"1.2.22","membership_expiration_date":"1970-01-01T00:00:00","registrar":"1.2.12","referrer":"1.2.12","lifetime_referrer":"1.2.12","network_fee_percentage":2000,"lifetime_referrer_fee_percentage":3000,"referrer_rewards_percentage":7500,"name":"vsharaev","owner":{"weight_threshold":1,"account_auths":[],"key_auths":[["ECHO6CNWcfkh4DhtbYtjZgMmwb49noxkPFwCu5pYjtNsK3K6XX6JpV",1]],"address_auths":[]},"active":{"weight_threshold":1,"account_auths":[],"key_auths":[["ECHO6CNWcfkh4DhtbYtjZgMmwb49noxkPFwCu5pYjtNsK3K6XX6JpV",1]],"address_auths":[]},"ed_key":"fd9370d6384ee109765616b2ec5337b221a53a1fa3f3a076b68fcf774994a914","options":{"memo_key":"ECHO6CNWcfkh4DhtbYtjZgMmwb49noxkPFwCu5pYjtNsK3K6XX6JpV","voting_account":"1.2.5","delegating_account":"1.2.12","num_witness":0,"num_committee":0,"votes":[],"extensions":[]},"statistics":"2.6.22","whitelisting_accounts":[],"blacklisting_accounts":[],"whitelisted_accounts":[],"blacklisted_accounts":[],"owner_special_authority":[0,{}],"active_special_authority":[0,{}],"top_n_control_flags":0},"statistics":{"id":"2.6.22","owner":"1.2.22","most_recent_op":"2.9.451","total_ops":16,"removed_ops":0,"total_core_in_orders":0,"lifetime_fees_paid":8067204,"pending_fees":0,"pending_vested_fees":155},"registrar_name":"nathan","referrer_name":"nathan","lifetime_referrer_name":"nathan","votes":[],"balances":[{"id":"2.5.11","owner":"1.2.22","asset_type":"1.3.0","balance":"9992032667"},{"id":"2.5.17","owner":"1.2.22","asset_type":"1.3.1","balance":999999960}],"vesting_balances":[],"limit_orders":[],"call_orders":[],"settle_orders":[],"proposals":[],"assets":[],"withdraws":[]}]]}
                """
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




