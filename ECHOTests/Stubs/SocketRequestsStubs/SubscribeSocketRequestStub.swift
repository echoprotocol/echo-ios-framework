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
        
        if id == 9 {
            return "{\"id\":9,\"jsonrpc\":\"2.0\",\"result\":[[\"1.2.163\",{\"account\":{\"id\":\"1.2.163\",\"membership_expiration_date\":\"1970-01-01T00:00:00\",\"registrar\":\"1.2.17\",\"referrer\":\"1.2.17\",\"lifetime_referrer\":\"1.2.17\",\"network_fee_percentage\":2000,\"lifetime_referrer_fee_percentage\":3000,\"referrer_rewards_percentage\":0,\"name\":\"nikita1994\",\"owner\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"ECHO5CavH12DSGiSgikSMqrobJrb1HhQiAn7vquFMhHwXVbH92dUC8\",1]],\"address_auths\":[]},\"active\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"ECHO5yj4S9KjQP9FGQRRQvU9mWELBNUdoXMvsuKtXmzZUAjhxfriT5\",1]],\"address_auths\":[]},\"options\":{\"memo_key\":\"ECHO8CdXYuB1Nt3G1xsg9a2jtHEgEcvyrkw4uHchSRpg4hwrcoT4uB\",\"voting_account\":\"1.2.5\",\"num_witness\":0,\"num_committee\":0,\"votes\":[],\"extensions\":[]},\"statistics\":\"2.6.163\",\"whitelisting_accounts\":[],\"blacklisting_accounts\":[],\"whitelisted_accounts\":[],\"blacklisted_accounts\":[],\"owner_special_authority\":[0,{}],\"active_special_authority\":[0,{}],\"top_n_control_flags\":0},\"statistics\":{\"id\":\"2.6.163\",\"owner\":\"1.2.163\",\"most_recent_op\":\"2.9.53637\",\"total_ops\":33,\"removed_ops\":0,\"total_core_in_orders\":0,\"lifetime_fees_paid\":0,\"pending_fees\":0,\"pending_vested_fees\":26005731},\"registrar_name\":\"nathan\",\"referrer_name\":\"nathan\",\"lifetime_referrer_name\":\"nathan\",\"votes\":[],\"balances\":[{\"id\":\"2.5.206\",\"owner\":\"1.2.163\",\"asset_type\":\"1.3.0\",\"balance\":69850519}],\"vesting_balances\":[],\"limit_orders\":[],\"call_orders\":[],\"settle_orders\":[],\"proposals\":[],\"assets\":[],\"withdraws\":[]}]]}"
        }
        
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":[[\"nikita1994\",{\"account\":{\"id\":\"1.2.163\",\"membership_expiration_date\":\"1970-01-01T00:00:00\",\"registrar\":\"1.2.17\",\"referrer\":\"1.2.17\",\"lifetime_referrer\":\"1.2.17\",\"network_fee_percentage\":2000,\"lifetime_referrer_fee_percentage\":3000,\"referrer_rewards_percentage\":0,\"name\":\"nikita1994\",\"owner\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"ECHO5CavH12DSGiSgikSMqrobJrb1HhQiAn7vquFMhHwXVbH92dUC8\",1]],\"address_auths\":[]},\"active\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"ECHO5yj4S9KjQP9FGQRRQvU9mWELBNUdoXMvsuKtXmzZUAjhxfriT5\",1]],\"address_auths\":[]},\"options\":{\"memo_key\":\"ECHO8CdXYuB1Nt3G1xsg9a2jtHEgEcvyrkw4uHchSRpg4hwrcoT4uB\",\"voting_account\":\"1.2.5\",\"num_witness\":0,\"num_committee\":0,\"votes\":[],\"extensions\":[]},\"statistics\":\"2.6.163\",\"whitelisting_accounts\":[],\"blacklisting_accounts\":[],\"whitelisted_accounts\":[],\"blacklisted_accounts\":[],\"owner_special_authority\":[0,{}],\"active_special_authority\":[0,{}],\"top_n_control_flags\":0},\"statistics\":{\"id\":\"2.6.163\",\"owner\":\"1.2.163\",\"most_recent_op\":\"2.9.53637\",\"total_ops\":33,\"removed_ops\":0,\"total_core_in_orders\":0,\"lifetime_fees_paid\":0,\"pending_fees\":0,\"pending_vested_fees\":26005731},\"registrar_name\":\"nathan\",\"referrer_name\":\"nathan\",\"lifetime_referrer_name\":\"nathan\",\"votes\":[],\"balances\":[{\"id\":\"2.5.206\",\"owner\":\"1.2.163\",\"asset_type\":\"1.3.0\",\"balance\":69850519}],\"vesting_balances\":[],\"limit_orders\":[],\"call_orders\":[],\"settle_orders\":[],\"proposals\":[],\"assets\":[],\"withdraws\":[]}]]}"
    }
}

struct SubscribeSocketRequestStubHodler: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [SetSubscriberSocketRequestElementStub(),
                                         AccountSocketRequestElementStub()]
}
