//
//  SubscribeSocketRequestStub.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 11/6/18.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct SetSubscriberSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "set_subscribe_callback"
    
    func createResponce(id: Int) -> String {
        
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":null}"
    }
}

struct AccountSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "get_full_accounts"
    
    func createResponce(id: Int) -> String {
        
        return """
                {"id":\(id),"jsonrpc":"2.0","result":[["1.2.33",{"account":{"id":"1.2.33","membership_expiration_date":"1970-01-01T00:00:00","registrar":"1.2.8","referrer":"1.2.8","lifetime_referrer":"1.2.8","network_fee_percentage":2000,"lifetime_referrer_fee_percentage":3000,"referrer_rewards_percentage":7500,"name":"vsharaev","owner":{"weight_threshold":1,"account_auths":[],"key_auths":[["ECHO7cXptTuBWfJ8L51afiUSZpaDto6jLVmjDreVpTe1kNYXqiPSP6",1]],"address_auths":[]},"active":{"weight_threshold":1,"account_auths":[],"key_auths":[["ECHO7cXptTuBWfJ8L51afiUSZpaDto6jLVmjDreVpTe1kNYXqiPSP6",1]],"address_auths":[]},"ed_key":"b0df210943223fa70a6e2283c6049e01b9081866959b0f1b4197dec8dc66d158","options":{"memo_key":"ECHO7cXptTuBWfJ8L51afiUSZpaDto6jLVmjDreVpTe1kNYXqiPSP6","voting_account":"1.2.5","delegating_account":"1.2.8","num_witness":0,"num_committee":0,"votes":[],"extensions":[]},"statistics":"2.6.33","whitelisting_accounts":[],"blacklisting_accounts":[],"whitelisted_accounts":[],"blacklisted_accounts":[],"owner_special_authority":[0,{}],"active_special_authority":[0,{}],"top_n_control_flags":0},"statistics":{"id":"2.6.33","owner":"1.2.33","most_recent_op":"2.9.21256","total_ops":747,"removed_ops":0,"total_core_in_orders":0,"lifetime_fees_paid":2109199,"pending_fees":0,"pending_vested_fees":144},"registrar_name":"init2","referrer_name":"init2","lifetime_referrer_name":"init2","votes":[],"balances":[{"id":"2.5.16","owner":"1.2.33","asset_type":"1.3.0","balance":"100097588664"},{"id":"2.5.34","owner":"1.2.33","asset_type":"1.3.9","balance":878199},{"id":"2.5.75","owner":"1.2.33","asset_type":"1.3.20","balance":9997480},{"id":"2.5.1239","owner":"1.2.33","asset_type":"1.3.21","balance":10000}],"vesting_balances":[],"limit_orders":[],"call_orders":[],"settle_orders":[],"proposals":[],"assets":["1.3.20"],"withdraws":[]}]]}
                """
    }
}

struct SubscribeSocketRequestStubHodler: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [SetSubscriberSocketRequestElementStub(),
                                         AccountSocketRequestElementStub()]
}
