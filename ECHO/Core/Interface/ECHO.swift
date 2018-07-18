//
//  ECHO.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public class ECHO: AuthentificationFacade {
    
    var revilFacade: RevialApiFacade
//    var subscriptionFacade: SubscriptionFacade
//    var informationFacade: InformationFacade
//    var feeFacade: FeeFacade
    var authentificationFacade: AuthentificationFacade

    public init(settings: Settings) {

        let socketCore = SocketCoreComponentImp(messanger: settings.socketMessenger, url: settings.url)
        let databaseService = DatabaseApiServiceImp(socketCore: socketCore)
        let cryptoService = CryptoApiServiceImp(socketCore: socketCore)
        let networkBroadcastService = NetworkBroadcastApiServiceImp(socketCore: socketCore)
        let historyService = AccountHistoryApiServiceImp(socketCore: socketCore)
        let networkNodesSetvice = NetworkNodesApiServiceImp(socketCore: socketCore)
        
        let revialServices = RevialFacadeServices(databaseService: databaseService,
                                                  cryptoService: cryptoService,
                                                  historyService: historyService,
                                                  networkBroadcastService: networkBroadcastService,
                                                  networkNodesService: networkNodesSetvice)
        
        revilFacade = RevialFacadeImp(socketCore: socketCore,
                                      options: settings.apiOptions,
                                      services: revialServices)
        
        let authServices = AuthentificationFacadeServices(databaseService: databaseService)
        
        authentificationFacade = AuthentificationFacadeImp(services: authServices)
        
    }
    
    public func start(completion: @escaping Completion<Bool>) {
        revilFacade.revilApi(completion: completion)
    }
    
    // MARK: AuthentificationFacade
    
    public func login(name: String, password: String, completion: @escaping (Result<UserAccount, ECHOError>) -> Void) {
        authentificationFacade.login(name: name, password: password, completion: completion)
    }
    
    public func changePassword(old: String, new: String, name: String, completion: @escaping (Result<UserAccount, ECHOError>) -> Void) {
        authentificationFacade.changePassword(old: old, new: new, name: name, completion: completion)
    }
}
