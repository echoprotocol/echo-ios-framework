//
//  IssueAssetSocketStubs.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 06.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct IssueAssetAccountSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "get_full_accounts"
    
    func createResponce(id: Int) -> String {
        return """
                {"id":\(id),"jsonrpc":"2.0","result":[["vsharaev",{"account":{"id":"1.2.22","membership_expiration_date":"1970-01-01T00:00:00","registrar":"1.2.12","referrer":"1.2.12","lifetime_referrer":"1.2.12","network_fee_percentage":2000,"lifetime_referrer_fee_percentage":3000,"referrer_rewards_percentage":7500,"name":"vsharaev","owner":{"weight_threshold":1,"account_auths":[],"key_auths":[["ECHO8Fs2D8nVEW3x5knWmNKAtTJdC1Zbw7kkxiG1DX5xoFAb1f9nLH",1]],"address_auths":[]},"active":{"weight_threshold":1,"account_auths":[],"key_auths":[["ECHO6CNWcfkh4DhtbYtjZgMmwb49noxkPFwCu5pYjtNsK3K6XX6JpV",1]],"address_auths":[]},"ed_key":"fd91760140895c694197664baeb5388bc9d9bb70b6ee13d087e0404758708418","options":{"memo_key":"ECHO7iMzBkAxXJkKy8vMMZ3JZmXHJ7jBz81rNxy1jkwyYXMNJkfVVY","voting_account":"1.2.5","delegating_account":"1.2.12","num_witness":0,"num_committee":0,"votes":[],"extensions":[]},"statistics":"2.6.22","whitelisting_accounts":[],"blacklisting_accounts":[],"whitelisted_accounts":[],"blacklisted_accounts":[],"owner_special_authority":[0,{}],"active_special_authority":[0,{}],"top_n_control_flags":0},"statistics":{"id":"2.6.22","owner":"1.2.22","most_recent_op":"2.9.451","total_ops":16,"removed_ops":0,"total_core_in_orders":0,"lifetime_fees_paid":8067204,"pending_fees":0,"pending_vested_fees":155},"registrar_name":"nathan","referrer_name":"nathan","lifetime_referrer_name":"nathan","votes":[],"balances":[{"id":"2.5.11","owner":"1.2.22","asset_type":"1.3.0","balance":"9992032667"},{"id":"2.5.17","owner":"1.2.22","asset_type":"1.3.1","balance":999999960}],"vesting_balances":[],"limit_orders":[],"call_orders":[],"settle_orders":[],"proposals":[],"assets":[],"withdraws":[]}]]}
                """
    }
}

struct IssueAssetFeeSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "get_required_fees"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":[{\"amount\":2010546,\"asset_id\":\"1.3.0\"}]}"
    }
}

struct IssueAssetChainIdSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "get_chain_id"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":\"233ae92c7218173c76b5ffad9487b063933eec714a12e3f2ea48026a45262934\"}"
    }
}

struct IssueAssetGlobalPropertiesSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "get_dynamic_global_properties"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":{\"id\":\"2.1.0\",\"head_block_number\":472207,\"head_block_id\":\"0007348f3522985283d7c0a566014ab62b9775a3\",\"time\":\"2018-09-06T10:25:20\",\"current_witness\":\"1.6.1\",\"next_maintenance_time\":\"2018-09-07T00:00:00\",\"last_budget_time\":\"2018-09-06T00:00:00\",\"witness_budget\":0,\"accounts_registered_this_interval\":3,\"recently_missed_count\":0,\"current_aslot\":5357591,\"recent_slots_filled\":\"340282366920938463463374607431768211455\",\"dynamic_flags\":0,\"last_irreversible_block_num\":472197}}"
    }
}

struct IssueAssetTransactionSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "broadcast_transaction_with_callback"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":null}"
    }
}

struct IssueAssetSocketRequestStubHodler: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [IssueAssetTransactionSocketRequestElementStub(),
                                         IssueAssetGlobalPropertiesSocketRequestElementStub(),
                                         IssueAssetChainIdSocketRequestElementStub(),
                                         IssueAssetFeeSocketRequestElementStub(),
                                         IssueAssetAccountSocketRequestElementStub()]
}
