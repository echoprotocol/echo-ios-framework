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
        {"id":\(id),"jsonrpc":"2.0","result":[["vsharaev",{"account":{"id":"1.2.29","membership_expiration_date":"1970-01-01T00:00:00","registrar":"1.2.12","referrer":"1.2.12","lifetime_referrer":"1.2.12","network_fee_percentage":2000,"lifetime_referrer_fee_percentage":3000,"referrer_rewards_percentage":7500,"name":"vsharaev","active":{"weight_threshold":1,"account_auths":[],"key_auths":[["DETCuS6J2FDbXQNVLa2a2D7XM1nESghyrSgvmKNLcyKiUN3",1]]},"ed_key":"DETFaQfpD7hieiydYUiU22mLyX8APPGhi4p5FdXajBsmMbJ","options":{"memo_key":"ECHO7cXptTuBWfJ8L51afiUSZpaDto6jLVmjDreVpTe1kNYXqiPSP6","voting_account":"1.2.5","delegating_account":"1.2.12","num_committee":0,"votes":[],"extensions":[]},"statistics":"2.6.29","whitelisting_accounts":[],"blacklisting_accounts":[],"whitelisted_accounts":[],"blacklisted_accounts":[],"owner_special_authority":[0,{}],"active_special_authority":[0,{}],"top_n_control_flags":0},"statistics":{"id":"2.6.29","owner":"1.2.29","most_recent_op":"2.9.339","total_ops":40,"removed_ops":0,"total_blocks":28,"total_core_in_orders":0,"lifetime_fees_paid":0,"pending_fees":0,"pending_vested_fees":6027773},"registrar_name":"nathan","referrer_name":"nathan","lifetime_referrer_name":"nathan","votes":[],"balances":[{"id":"2.5.13","owner":"1.2.29","asset_type":"1.3.0","balance":993972149},{"id":"2.5.18","owner":"1.2.29","asset_type":"1.3.1","balance":99594},{"id":"2.5.14","owner":"1.2.29","asset_type":"1.3.3","balance":9999920}],"vesting_balances":[],"limit_orders":[],"call_orders":[],"settle_orders":[],"proposals":[],"assets":["1.3.3"],"withdraws":[]}],["vsharaev1",{"account":{"id":"1.2.30","membership_expiration_date":"1970-01-01T00:00:00","registrar":"1.2.12","referrer":"1.2.12","lifetime_referrer":"1.2.12","network_fee_percentage":2000,"lifetime_referrer_fee_percentage":3000,"referrer_rewards_percentage":7500,"name":"vsharaev1","active":{"weight_threshold":1,"account_auths":[],"key_auths":[["DET8wNAGiYqv82j1V7pVdnAYDNFcnf9SyiUVBkkvUrkGPgQ",1]]},"ed_key":"DET2JL7uYmBdN7YYS1Fz3VjHCTtuZwWSxgWEaSRzQq4dsce","options":{"memo_key":"ECHO6wmiMHQ6QyDTqNzSXANHUmGD8Pubtm68MQquHsixSRKzJNmUAP","voting_account":"1.2.5","delegating_account":"1.2.12","num_committee":0,"votes":[],"extensions":[]},"statistics":"2.6.30","whitelisting_accounts":[],"blacklisting_accounts":[],"whitelisted_accounts":[],"blacklisted_accounts":[],"owner_special_authority":[0,{}],"active_special_authority":[0,{}],"top_n_control_flags":0},"statistics":{"id":"2.6.30","owner":"1.2.30","most_recent_op":"2.9.305","total_ops":9,"removed_ops":0,"total_blocks":0,"total_core_in_orders":0,"lifetime_fees_paid":0,"pending_fees":0,"pending_vested_fees":0},"registrar_name":"nathan","referrer_name":"nathan","lifetime_referrer_name":"nathan","votes":[],"balances":[{"id":"2.5.15","owner":"1.2.30","asset_type":"1.3.0","balance":8}],"vesting_balances":[],"limit_orders":[],"call_orders":[],"settle_orders":[],"proposals":[],"assets":[],"withdraws":[]}]]}
        """
    }
}

struct GetFullAccountsByIdSocketRequestStub: SocketRequestStub {
    
    var operationType = "get_full_accounts"
    
    func createResponce(id: Int) -> String {
        
        return """
        {"id":\(id),"jsonrpc":"2.0","result":[["1.2.29",{"account":{"id":"1.2.29","membership_expiration_date":"1970-01-01T00:00:00","registrar":"1.2.12","referrer":"1.2.12","lifetime_referrer":"1.2.12","network_fee_percentage":2000,"lifetime_referrer_fee_percentage":3000,"referrer_rewards_percentage":7500,"name":"vsharaev","active":{"weight_threshold":1,"account_auths":[],"key_auths":[["DETCuS6J2FDbXQNVLa2a2D7XM1nESghyrSgvmKNLcyKiUN3",1]]},"ed_key":"DETFaQfpD7hieiydYUiU22mLyX8APPGhi4p5FdXajBsmMbJ","options":{"memo_key":"ECHO7cXptTuBWfJ8L51afiUSZpaDto6jLVmjDreVpTe1kNYXqiPSP6","voting_account":"1.2.5","delegating_account":"1.2.12","num_committee":0,"votes":[],"extensions":[]},"statistics":"2.6.29","whitelisting_accounts":[],"blacklisting_accounts":[],"whitelisted_accounts":[],"blacklisted_accounts":[],"owner_special_authority":[0,{}],"active_special_authority":[0,{}],"top_n_control_flags":0},"statistics":{"id":"2.6.29","owner":"1.2.29","most_recent_op":"2.9.339","total_ops":40,"removed_ops":0,"total_blocks":28,"total_core_in_orders":0,"lifetime_fees_paid":0,"pending_fees":0,"pending_vested_fees":6027773},"registrar_name":"nathan","referrer_name":"nathan","lifetime_referrer_name":"nathan","votes":[],"balances":[{"id":"2.5.13","owner":"1.2.29","asset_type":"1.3.0","balance":993972149},{"id":"2.5.18","owner":"1.2.29","asset_type":"1.3.1","balance":99594},{"id":"2.5.14","owner":"1.2.29","asset_type":"1.3.3","balance":9999920}],"vesting_balances":[],"limit_orders":[],"call_orders":[],"settle_orders":[],"proposals":[],"assets":["1.3.3"],"withdraws":[]}],["vsharaev1",{"account":{"id":"1.2.30","membership_expiration_date":"1970-01-01T00:00:00","registrar":"1.2.12","referrer":"1.2.12","lifetime_referrer":"1.2.12","network_fee_percentage":2000,"lifetime_referrer_fee_percentage":3000,"referrer_rewards_percentage":7500,"name":"vsharaev1","active":{"weight_threshold":1,"account_auths":[],"key_auths":[["DET8wNAGiYqv82j1V7pVdnAYDNFcnf9SyiUVBkkvUrkGPgQ",1]]},"ed_key":"DET2JL7uYmBdN7YYS1Fz3VjHCTtuZwWSxgWEaSRzQq4dsce","options":{"memo_key":"ECHO6wmiMHQ6QyDTqNzSXANHUmGD8Pubtm68MQquHsixSRKzJNmUAP","voting_account":"1.2.5","delegating_account":"1.2.12","num_committee":0,"votes":[],"extensions":[]},"statistics":"2.6.30","whitelisting_accounts":[],"blacklisting_accounts":[],"whitelisted_accounts":[],"blacklisted_accounts":[],"owner_special_authority":[0,{}],"active_special_authority":[0,{}],"top_n_control_flags":0},"statistics":{"id":"2.6.30","owner":"1.2.30","most_recent_op":"2.9.305","total_ops":9,"removed_ops":0,"total_blocks":0,"total_core_in_orders":0,"lifetime_fees_paid":0,"pending_fees":0,"pending_vested_fees":0},"registrar_name":"nathan","referrer_name":"nathan","lifetime_referrer_name":"nathan","votes":[],"balances":[{"id":"2.5.15","owner":"1.2.30","asset_type":"1.3.0","balance":8}],"vesting_balances":[],"limit_orders":[],"call_orders":[],"settle_orders":[],"proposals":[],"assets":[],"withdraws":[]}]]}
        """
    }
}
