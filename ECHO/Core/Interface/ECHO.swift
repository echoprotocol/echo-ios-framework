//
//  ECHO.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public class ECHO {
    
    var revilFacade: RevialApiFacade

    public init(settings: Settings) {
        
        let databaseService = DatabaseApiServiceImp()
        let cryptoService = CryptoApiServiceImp()
        let networkBroadcastService = NetworkBroadcastApiServiceImp()
        let historyService = AccountHistoryApiServiceImp()
        let networkNodesSetvice = NetworkNodesApiServiceImp()
        
        let revialServices = RevialFacadeServices(databaseService: databaseService,
                                                  cryptoService: cryptoService,
                                                  historyService: historyService,
                                                  networkBroadcastService: networkBroadcastService,
                                                  networkNodesService: networkNodesSetvice)
        
        revilFacade = RevialFacadeImp(messanger: settings.socketMessenger,
                                      url: settings.url,
                                      options: settings.apiOptions,
                                      services: revialServices)
    }
    
    public func start(completion: @escaping Completion<Bool>) {
        revilFacade.revilApi(completion: completion)
    }
}
