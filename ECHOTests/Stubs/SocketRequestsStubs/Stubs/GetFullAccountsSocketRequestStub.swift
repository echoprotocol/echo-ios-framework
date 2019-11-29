//
//  GetFullAccountsSocketRequestStub.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 10/04/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

struct GetFullAccountsSocketRequestStub: SocketRequestStub {
    
    var operationType = "get_full_accounts"
    
    func createResponce(id: Int) -> String {
        
        return """
        {"id":\(id),"jsonrpc":"2.0","result":[["vsharaev",{"account":{"id":"1.2.48","membership_expiration_date":"1970-01-01T00:00:00","registrar":"1.2.12","referrer":"1.2.12","lifetime_referrer":"1.2.12","lifetime_referrer_fee_percentage":3000,"referrer_rewards_percentage":7500,"name":"vsharaev","active":{"weight_threshold":1,"account_auths":[],"key_auths":[["ECHOCuS6J2FDbXQNVLa2a2D7XM1nESghyrSgvmKNLcyKiUN3",1]]},"echorand_key":"ECHOCuS6J2FDbXQNVLa2a2D7XM1nESghyrSgvmKNLcyKiUN3","options":{"delegating_account":"1.2.12","extensions":[]},"statistics":"2.6.48","whitelisting_accounts":[],"blacklisting_accounts":[],"whitelisted_accounts":[],"blacklisted_accounts":[],"active_special_authority":[0,{}],"top_n_control_flags":0},"statistics":{"id":"2.6.48","owner":"1.2.48","most_recent_op":"2.9.527","total_ops":43,"removed_ops":0,"total_blocks":44,"total_core_in_orders":0,"lifetime_fees_paid":0,"pending_vested_fees":10239295},"registrar_name":"nathan","referrer_name":"nathan","lifetime_referrer_name":"nathan","balances":[{"id":"2.5.14","owner":"1.2.48","asset_type":"1.3.0","balance":989260663},{"id":"2.5.19","owner":"1.2.48","asset_type":"1.3.1","balance":199797},{"id":"2.5.15","owner":"1.2.48","asset_type":"1.3.3","balance":9999880}],"vesting_balances":[],"limit_orders":[],"call_orders":[],"settle_orders":[],"proposals":[],"assets":["1.3.3"],"withdraws":[]}],["vsharaev1",{"account":{"id":"1.2.51","membership_expiration_date":"1970-01-01T00:00:00","registrar":"1.2.12","referrer":"1.2.12","lifetime_referrer":"1.2.12","lifetime_referrer_fee_percentage":3000,"referrer_rewards_percentage":7500,"name":"vsharaev1","active":{"weight_threshold":1,"account_auths":[],"key_auths":[["ECHO8wNAGiYqv82j1V7pVdnAYDNFcnf9SyiUVBkkvUrkGPgQ",1]]},"echorand_key":"ECHO2JL7uYmBdN7YYS1Fz3VjHCTtuZwWSxgWEaSRzQq4dsce","options":{"delegating_account":"1.2.12","extensions":[]},"statistics":"2.6.51","whitelisting_accounts":[],"blacklisting_accounts":[],"whitelisted_accounts":[],"blacklisted_accounts":[],"active_special_authority":[0,{}],"top_n_control_flags":0},"statistics":{"id":"2.6.51","owner":"1.2.51","most_recent_op":"2.9.523","total_ops":15,"removed_ops":0,"total_blocks":0,"total_core_in_orders":0,"lifetime_fees_paid":0,"pending_vested_fees":200000},"registrar_name":"nathan","referrer_name":"nathan","lifetime_referrer_name":"nathan","balances":[{"id":"2.5.16","owner":"1.2.51","asset_type":"1.3.0","balance":300012}],"vesting_balances":[],"limit_orders":[],"call_orders":[],"settle_orders":[],"proposals":[],"assets":[],"withdraws":[]}]]}
        """
    }
}

struct GetFullAccountsByIdSocketRequestStub: SocketRequestStub {
    
    var operationType = "get_full_accounts"
    
    func createResponce(id: Int) -> String {
        
        return """
        {"id":\(id),"jsonrpc":"2.0","result":[["1.2.48",{"account":{"id":"1.2.48","membership_expiration_date":"1970-01-01T00:00:00","registrar":"1.2.12","referrer":"1.2.12","lifetime_referrer":"1.2.12","lifetime_referrer_fee_percentage":3000,"referrer_rewards_percentage":7500,"name":"vsharaev","active":{"weight_threshold":1,"account_auths":[],"key_auths":[["ECHOCuS6J2FDbXQNVLa2a2D7XM1nESghyrSgvmKNLcyKiUN3",1]]},"echorand_key":"ECHOCuS6J2FDbXQNVLa2a2D7XM1nESghyrSgvmKNLcyKiUN3","options":{"delegating_account":"1.2.12","extensions":[]},"statistics":"2.6.48","whitelisting_accounts":[],"blacklisting_accounts":[],"whitelisted_accounts":[],"blacklisted_accounts":[],"active_special_authority":[0,{}],"top_n_control_flags":0},"statistics":{"id":"2.6.48","owner":"1.2.48","most_recent_op":"2.9.527","total_ops":43,"removed_ops":0,"total_blocks":44,"total_core_in_orders":0,"lifetime_fees_paid":0,"pending_vested_fees":10239295},"registrar_name":"nathan","referrer_name":"nathan","lifetime_referrer_name":"nathan","balances":[{"id":"2.5.14","owner":"1.2.48","asset_type":"1.3.0","balance":989260663},{"id":"2.5.19","owner":"1.2.48","asset_type":"1.3.1","balance":199797},{"id":"2.5.15","owner":"1.2.48","asset_type":"1.3.3","balance":9999880}],"vesting_balances":[],"limit_orders":[],"call_orders":[],"settle_orders":[],"proposals":[],"assets":["1.3.3"],"withdraws":[]}],["vsharaev1",{"account":{"id":"1.2.51","membership_expiration_date":"1970-01-01T00:00:00","registrar":"1.2.12","referrer":"1.2.12","lifetime_referrer":"1.2.12","lifetime_referrer_fee_percentage":3000,"referrer_rewards_percentage":7500,"name":"vsharaev1","active":{"weight_threshold":1,"account_auths":[],"key_auths":[["ECHO8wNAGiYqv82j1V7pVdnAYDNFcnf9SyiUVBkkvUrkGPgQ",1]]},"echorand_key":"ECHO2JL7uYmBdN7YYS1Fz3VjHCTtuZwWSxgWEaSRzQq4dsce","options":{"delegating_account":"1.2.12","extensions":[]},"statistics":"2.6.51","whitelisting_accounts":[],"blacklisting_accounts":[],"whitelisted_accounts":[],"blacklisted_accounts":[],"active_special_authority":[0,{}],"top_n_control_flags":0},"statistics":{"id":"2.6.51","owner":"1.2.51","most_recent_op":"2.9.523","total_ops":15,"removed_ops":0,"total_blocks":0,"total_core_in_orders":0,"lifetime_fees_paid":0,"pending_vested_fees":200000},"registrar_name":"nathan","referrer_name":"nathan","lifetime_referrer_name":"nathan","balances":[{"id":"2.5.16","owner":"1.2.51","asset_type":"1.3.0","balance":300012}],"vesting_balances":[],"limit_orders":[],"call_orders":[],"settle_orders":[],"proposals":[],"assets":[],"withdraws":[]}]]}
        """
    }
}
