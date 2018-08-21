//
//  ECHO.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public typealias InterfaceFacades = AuthentificationFacade & InformationFacade & SubscriptionFacade

public class ECHO: InterfaceFacades {
    
    let revealFacade: RevealApiFacade
    let subscriptionFacade: SubscriptionFacade
    let informationFacade: InformationFacade
    let authentificationFacade: AuthentificationFacade

    public init(settings: Settings) {

        let socketCore = SocketCoreComponentImp(messanger: settings.socketMessenger, url: settings.url)
        let databaseService = DatabaseApiServiceImp(socketCore: socketCore)
        let cryptoService = CryptoApiServiceImp(socketCore: socketCore)
        let networkBroadcastService = NetworkBroadcastApiServiceImp(socketCore: socketCore)
        let historyService = AccountHistoryApiServiceImp(socketCore: socketCore)
        let networkNodesSetvice = NetworkNodesApiServiceImp(socketCore: socketCore)
        
        let revealServices = RevealFacadeServices(databaseService: databaseService,
                                                  cryptoService: cryptoService,
                                                  historyService: historyService,
                                                  networkBroadcastService: networkBroadcastService,
                                                  networkNodesService: networkNodesSetvice)
        
        revealFacade = RevealFacadeImp(socketCore: socketCore,
                                      options: settings.apiOptions,
                                      services: revealServices)
        
        let authServices = AuthentificationFacadeServices(databaseService: databaseService)
        authentificationFacade = AuthentificationFacadeImp(services: authServices, core: settings.cryproComponent)
        
        let informationServices = InformationFacadeServices(databaseService: databaseService,
                                                            historyService: historyService)
        informationFacade = InformationFacadeImp(services: informationServices)
        
        let subscriptionServices = SubscriptionServices(databaseService: databaseService)
        subscriptionFacade = SubscriptionFacadeImp(services: subscriptionServices,
                                                   socketCore: socketCore)
    }
    
    public func start(completion: @escaping Completion<Bool>) {
        revealFacade.revealApi(completion: completion)
    }
    
    // MARK: SubscriptionFacade
    
    public func subscribeToAccount(nameOrId: String, delegate: SubscribeAccountDelegate) {
        subscriptionFacade.subscribeToAccount(nameOrId: nameOrId, delegate: delegate)
    }
    
    public func unsubscribeToAccount(nameOrId: String, delegate: SubscribeAccountDelegate) {
        unsubscribeToAccount(nameOrId: nameOrId, delegate: delegate)
    }
    
    public func unsubscribeAll(completion: Completion<Bool>) {
        unsubscribeAll(completion: completion)
    }
    
    // MARK: AuthentificationFacade
    
    public func isOwnedBy(name: String, password: String, completion: @escaping Completion<UserAccount>) {
        authentificationFacade.isOwnedBy(name: name, password: password, completion: completion)
    }
    
    public func changePassword(old: String, new: String, name: String, completion: @escaping Completion<UserAccount>) {
        authentificationFacade.changePassword(old: old, new: new, name: name, completion: completion)
    }
    
    // MARK: InformationFacade
    
    public func getAccount(nameOrID: String, completion: @escaping Completion<Account>) {
        informationFacade.getAccount(nameOrID: nameOrID, completion: completion)
    }
    
    public func isAccauntReserved(nameOrID: String, completion: @escaping Completion<Bool>) {
        informationFacade.isAccauntReserved(nameOrID: nameOrID, completion: completion)
    }
    
    public func getBalance(nameOrID: String, asset: String?, completion: @escaping Completion<[AccountBalance]>) {
        informationFacade.getBalance(nameOrID: nameOrID, asset: asset, completion: completion)
    }
    
    public func getAccountHistroy(id: String, startId: String, stopId: String, limit: Int, completion: @escaping Completion<[Any]>) {
        informationFacade.getAccountHistroy(id: id, startId: startId, stopId: stopId, limit: limit, completion: completion)
    }

}
