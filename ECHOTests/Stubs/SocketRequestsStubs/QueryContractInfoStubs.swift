//
//  QueryContractInfoStubs.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 14.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct QueryContractStubs: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [QueryContractCallSocketRequestElementStub(),
                                         QueryContractAccountSocketRequestElementStub()]
}

struct QueryContractAccountSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "get_full_accounts"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":[[\"dariatest2\",{\"account\":{\"id\":\"1.2.22\",\"membership_expiration_date\":\"1970-01-01T00:00:00\",\"registrar\":\"1.2.17\",\"referrer\":\"1.2.17\",\"lifetime_referrer\":\"1.2.17\",\"network_fee_percentage\":2000,\"lifetime_referrer_fee_percentage\":3000,\"referrer_rewards_percentage\":0,\"name\":\"dariatest2\",\"owner\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"ECHO5n3RpLohzYp9iD488LTSY7VY7o8BZK93o2tWP4qbog8CjrxFh8\",1]],\"address_auths\":[]},\"active\":{\"weight_threshold\":1,\"account_auths\":[],\"key_auths\":[[\"ECHO8cCgwTUenjug1ii5g78UXd6Gaz2Ek2ee9NyYrTNrrVcJEnFSxD\",1]],\"address_auths\":[]},\"options\":{\"memo_key\":\"ECHO8cCgwTUenjug1ii5g78UXd6Gaz2Ek2ee9NyYrTNrrVcJEnFSxD\",\"voting_account\":\"1.2.5\",\"num_witness\":0,\"num_committee\":0,\"votes\":[],\"extensions\":[]},\"statistics\":\"2.6.22\",\"whitelisting_accounts\":[],\"blacklisting_accounts\":[],\"whitelisted_accounts\":[],\"blacklisted_accounts\":[],\"owner_special_authority\":[0,{}],\"active_special_authority\":[0,{}],\"top_n_control_flags\":0},\"statistics\":{\"id\":\"2.6.22\",\"owner\":\"1.2.22\",\"most_recent_op\":\"2.9.55361\",\"total_ops\":79,\"removed_ops\":0,\"total_core_in_orders\":0,\"lifetime_fees_paid\":10042453,\"pending_fees\":0,\"pending_vested_fees\":0},\"registrar_name\":\"nathan\",\"referrer_name\":\"nathan\",\"lifetime_referrer_name\":\"nathan\",\"votes\":[],\"balances\":[{\"id\":\"2.5.7\",\"owner\":\"1.2.22\",\"asset_type\":\"1.3.0\",\"balance\":87513297},{\"id\":\"2.5.19\",\"owner\":\"1.2.22\",\"asset_type\":\"1.3.18\",\"balance\":10000},{\"id\":\"2.5.31\",\"owner\":\"1.2.22\",\"asset_type\":\"1.3.24\",\"balance\":10980000}],\"vesting_balances\":[],\"limit_orders\":[],\"call_orders\":[],\"settle_orders\":[],\"proposals\":[],\"assets\":[\"1.3.22\",\"1.3.24\"],\"withdraws\":[]}]]}"
    }
}

struct QueryContractCallSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "call_contract_no_changing_state"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":\"000000000000000000000000000000000000000000000000000000000000003a\"}"
    }
}

