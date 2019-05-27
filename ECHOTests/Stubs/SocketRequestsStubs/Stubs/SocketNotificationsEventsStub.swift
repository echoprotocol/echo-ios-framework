//
//  SocketNotificationsEventsStub.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 29.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct TransactionEventEventNotificationStub {
    
    static let response1 = """
                            {"method":"notice","params":[8,[[{"id":"2.6.29","owner":"1.2.29","most_recent_op":"2.9.520","total_ops":45,"removed_ops":0,"total_blocks":52,"total_core_in_orders":0,"lifetime_fees_paid":0,"pending_fees":0,"pending_vested_fees":6027813},{"id":"2.5.13","owner":"1.2.29","asset_type":"1.3.0","balance":993972107}]]]}
                        """
    
    static let response2 = """
                            {"method":"notice","params":[8,[[{"id":"2.6.29","owner":"1.2.29","most_recent_op":"2.9.520","total_ops":45,"removed_ops":0,"total_blocks":53,"total_core_in_orders":0,"lifetime_fees_paid":0,"pending_fees":0,"pending_vested_fees":6027813}]]]}
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
