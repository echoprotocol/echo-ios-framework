//
//  CustomOperationsFacadeImp.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 19/11/2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public struct CustomOperationsFacadeServices {
    
    var databaseService: DatabaseApiService
    var cryptoService: CryptoApiService
    var networkBroadcastService: NetworkBroadcastApiService
    var historyService: AccountHistoryApiService
    var networkNodesService: NetworkNodesApiService
    var registrationService: RegistrationApiService
}

/**
    Implementation of [CustomOperationsFacade](CustomOperationsFacade)
 */
final public class CustomOperationsFacadeImp: CustomOperationsFacade {
    
    let services: CustomOperationsFacadeServices
    
    public init(services: CustomOperationsFacadeServices) {
        
        self.services = services
    }
    
    public func sendCustomOperation(operation: CustomSocketOperation, for specificAPI: API) {
        
        var service: BaseApiService
        
        switch specificAPI {
        case .database:
            service = services.databaseService
        case .accountHistory:
            service = services.historyService
        case .crypto:
            service = services.cryptoService
        case .networkBroadcast:
            service = services.networkBroadcastService
        case .networkNodes:
            service = services.networkNodesService
        case .registration:
            service = services.registrationService
        }
        
        service.sendCustomOperation(operation: operation)
    }
}
