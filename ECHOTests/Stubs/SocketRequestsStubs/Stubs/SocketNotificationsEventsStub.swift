//
//  SocketNotificationsEventsStub.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 29.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct TransactionEventEventNotificationStub {
    
    static let response1 = """
                            {"method":"notice","params":[8,[[{"id":"2.1.0","head_block_number":615727,"head_block_id":"0009652fe6fdac4e422ffafb4efb5b7578adaeb6","time":"2019-04-01T11:00:53","current_witness":"1.6.0","next_maintenance_time":"2019-04-02T00:00:00","last_budget_time":"2019-04-01T00:00:00","witness_budget":0,"accounts_registered_this_interval":31,"recently_missed_count":0,"current_aslot":615727,"recent_slots_filled":"340282366920938463463374607431768211455","dynamic_flags":0,"last_irreversible_block_num":615712},{"id":"1.6.0","witness_account":"1.2.0","last_aslot":615727,"signing_key":"ECHO1111111111111111111111111111111114T1Anm","pay_vb":"1.13.1","vote_id":"1:0","total_votes":0,"url":"","total_missed":0,"last_confirmed_block_num":615727,"ed_signing_key":"0000000000000000000000000000000000000000000000000000000000000000"},{"id":"2.5.74","owner":"1.2.82","asset_type":"1.3.0","balance":100000253},{"id":"2.8.25903","block_id":"0009652fe6fdac4e422ffafb4efb5b7578adaeb6"},{"id":"2.6.33","owner":"1.2.33","most_recent_op":"2.9.21230","total_ops":746,"removed_ops":0,"total_core_in_orders":0,"lifetime_fees_paid":2109199,"pending_fees":0,"pending_vested_fees":144},{"id":"2.5.16","owner":"1.2.33","asset_type":"1.3.0","balance":"100097588664"}]]]}
                        """
    
    static let response2 = """
                            {"method":"notice","params":[8,[[{"id":"2.1.0","head_block_number":615727,"head_block_id":"0009652f182df0964af2b4a2837ce57ad1277196","time":"2019-04-01T11:00:53","current_witness":"1.6.0","next_maintenance_time":"2019-04-02T00:00:00","last_budget_time":"2019-04-01T00:00:00","witness_budget":0,"accounts_registered_this_interval":31,"recently_missed_count":0,"current_aslot":615727,"recent_slots_filled":"340282366920938463463374607431768211455","dynamic_flags":0,"last_irreversible_block_num":615712},{"id":"1.6.0","witness_account":"1.2.0","last_aslot":615727,"signing_key":"ECHO1111111111111111111111111111111114T1Anm","pay_vb":"1.13.1","vote_id":"1:0","total_votes":0,"url":"","total_missed":0,"last_confirmed_block_num":615727,"ed_signing_key":"0000000000000000000000000000000000000000000000000000000000000000"},{"id":"2.5.74","owner":"1.2.82","asset_type":"1.3.0","balance":100000253},{"id":"2.8.25903","block_id":"0009652f182df0964af2b4a2837ce57ad1277196"},{"id":"2.6.33","owner":"1.2.33","most_recent_op":"2.9.21230","total_ops":746,"removed_ops":0,"total_core_in_orders":0,"lifetime_fees_paid":2109199,"pending_fees":0,"pending_vested_fees":144},{"id":"2.5.16","owner":"1.2.33","asset_type":"1.3.0","balance":"100097588664"}]]]}
                            """
    
    static let response3 = """
                            {"method":"notice","params":[14,[{"id":"f7f81ddc81009772385b965db46dcf341154d2e4","block_num":615727,"trx_num":0,"trx":{"ref_block_num":25901,"ref_block_prefix":2748760341,"expiration":"2019-04-01T11:01:31","operations":[[0,{"fee":{"amount":20,"asset_id":"1.3.0"},"from":"1.2.33","to":"1.2.82","amount":{"amount":1,"asset_id":"1.3.0"},"extensions":[]}]],"extensions":[],"signatures":["20308963fa050e9d348a5254a2fc02c321c9af6c6ac4b2fb7ec1f226d5faccea3f3af415cc911b8f9d647e105f497f3807f08b261efeb7412e01bda1b78a81ca14"],"operation_results":[[0,{}]]}}]]}
                            """
    
    static let response4 = """
                            {"method":"notice","params":[8,[[{"id":"2.5.16","owner":"1.2.33","asset_type":"1.3.0","balance":"100097588664"},{"id":"2.6.82","owner":"1.2.82","most_recent_op":"2.9.21257","total_ops":255,"removed_ops":0,"total_core_in_orders":0,"lifetime_fees_paid":0,"pending_fees":0,"pending_vested_fees":0},{"id":"2.8.25903","block_id":"0009652f182df0964af2b4a2837ce57ad1277196"},{"id":"2.5.74","owner":"1.2.82","asset_type":"1.3.0","balance":100000253},{"id":"2.6.33","owner":"1.2.33","most_recent_op":"2.9.21256","total_ops":747,"removed_ops":0,"total_core_in_orders":0,"lifetime_fees_paid":2109199,"pending_fees":0,"pending_vested_fees":144},{"id":"1.6.0","witness_account":"1.2.0","last_aslot":615727,"signing_key":"ECHO1111111111111111111111111111111114T1Anm","pay_vb":"1.13.1","vote_id":"1:0","total_votes":0,"url":"","total_missed":0,"last_confirmed_block_num":615727,"ed_signing_key":"0000000000000000000000000000000000000000000000000000000000000000"},{"id":"2.1.0","head_block_number":615727,"head_block_id":"0009652f182df0964af2b4a2837ce57ad1277196","time":"2019-04-01T11:00:53","current_witness":"1.6.0","next_maintenance_time":"2019-04-02T00:00:00","last_budget_time":"2019-04-01T00:00:00","witness_budget":0,"accounts_registered_this_interval":31,"recently_missed_count":0,"current_aslot":615727,"recent_slots_filled":"340282366920938463463374607431768211455","dynamic_flags":0,"last_irreversible_block_num":615712}]]]}
                            """
}

struct ContractLogsEventNotificationStub {
    
    static let response1 = """
                            {"method":"notice","params":[10,[[{"address":"0100000000000000000000000000000000000324","log":["a7659801d76e732d0b4c81221c99e5cf387816232f81f4ff646ba0653d65507a"],"data":"00000000000000000000000000000000000000000000000000000000000c04d1"},{"address":"0100000000000000000000000000000000000324","log":["a7659801d76e732d0b4c81221c99e5cf387816232f81f4ff646ba0653d65507a"],"data":"0000000000000000000000000000000000000000000000000000000000000001"}]]]}
                        """
    
    static let response2 = """
                            {"method":"notice","params":[14,[{"id":"b1d2c0b5b4892b4d6c5d81a83777ef1345cf691b","block_num":787666,"trx_num":0,"trx":{"ref_block_num":1232,"ref_block_prefix":4156738382,"expiration":"2019-04-01T13:41:31","operations":[[48,{"fee":{"amount":124,"asset_id":"1.3.0"},"registrar":"1.2.264","value":{"amount":0,"asset_id":"1.3.0"},"code":"29e99f070000000000000000000000000000000000000000000000000000000000000001","callee":"1.16.804"}]],"extensions":[],"signatures":["2055d703d8fcb215802ae9edc2010639a85858e07f97f01fac91094135f20ba26405bbed1473a86cd927da4de11602df821309af43475418182d1beca39c7f56b4"],"operation_results":[[1,"1.17.695"]]}}]]}
                            """
}
