//
//  ECHO.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

typealias InterfaceFacades = AuthentificationFacade
    & InformationFacade
    & SubscriptionFacade
    & FeeFacade
    & TransactionFacade
    & AssetsFacade

/**
     This is an  entry point of library.
 
     ## Important Notes ##
     1. All functions provided by the library are enclosed in this class.
     2. It is possible to replace standard classes of work with cryptography and a socket
     3. Modification of the library parameters is done using the **Settings** class in the constructor of the class
 */
final public class ECHO: InterfaceFacades {
    
    let revealFacade: RevealApiFacade
    let subscriptionFacade: SubscriptionFacade
    let informationFacade: InformationFacade
    let authentificationFacade: AuthentificationFacade
    let feeFacade: FeeFacade
    let transacitonFacade: TransactionFacade
    let assetsFacade: AssetsFacade

    public init(settings: Settings) {

        let socketCore = SocketCoreComponentImp(messanger: settings.socketMessenger, url: settings.network.url)
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
        
        let authServices = AuthentificationFacadeServices(databaseService: databaseService, networkBroadcastService: networkBroadcastService)
        authentificationFacade = AuthentificationFacadeImp(services: authServices, core: settings.cryproComponent, network: settings.network)
        
        let informationServices = InformationFacadeServices(databaseService: databaseService,
                                                            historyService: historyService)
        informationFacade = InformationFacadeImp(services: informationServices)
        
        let subscriptionServices = SubscriptionServices(databaseService: databaseService)
        subscriptionFacade = SubscriptionFacadeImp(services: subscriptionServices,
                                                   socketCore: socketCore)
        
        let feeServices = FeeFacadeServices(databaseService: databaseService)
        feeFacade = FeeFacadeImp(services: feeServices)
        
        let transactoinServices = TransactionFacadeServices(databaseService: databaseService, networkBroadcastService: networkBroadcastService)
        transacitonFacade = TransactionFacadeImp(services: transactoinServices, cryptoCore: settings.cryproComponent, network: settings.network)
        
        let assetsServices = AssetsServices(databaseService: databaseService, networkBroadcastService: networkBroadcastService)
        assetsFacade = AssetsFacadeImp(services: assetsServices, cryptoCore: settings.cryproComponent, network: settings.network)
    }
    
/**
     Starts socket connection, connects to blockchain apis
 */
    public func start(completion: @escaping Completion<Bool>) {
        revealFacade.revealApi(completion: completion)
    }
    
    // MARK: SubscriptionFacade
    
    public func subscribeToAccount(nameOrId: String, delegate: SubscribeAccountDelegate) {
        subscriptionFacade.subscribeToAccount(nameOrId: nameOrId, delegate: delegate)
    }
    
    public func unsubscribeToAccount(nameOrId: String, delegate: SubscribeAccountDelegate) {
        subscriptionFacade.unsubscribeToAccount(nameOrId: nameOrId, delegate: delegate)
    }
    
    public func unsubscribeAll() {
        subscriptionFacade.unsubscribeAll()
    }
    
    // MARK: AuthentificationFacade
    
    public func isOwnedBy(name: String, password: String, completion: @escaping Completion<UserAccount>) {
        authentificationFacade.isOwnedBy(name: name, password: password, completion: completion)
    }
    
    public func changePassword(old: String, new: String, name: String, completion: @escaping Completion<Bool>) {
        authentificationFacade.changePassword(old: old, new: new, name: name, completion: completion)
    }
    
    // MARK: InformationFacade
    
    public func getAccount(nameOrID: String, completion: @escaping Completion<Account>) {
        informationFacade.getAccount(nameOrID: nameOrID, completion: completion)
    }
    
    public func isAccountReserved(nameOrID: String, completion: @escaping Completion<Bool>) {
        informationFacade.isAccountReserved(nameOrID: nameOrID, completion: completion)
    }
    
    public func getBalance(nameOrID: String, asset: String?, completion: @escaping Completion<[AccountBalance]>) {
        informationFacade.getBalance(nameOrID: nameOrID, asset: asset, completion: completion)
    }
    
    public func getAccountHistroy(nameOrID: String, startId: String, stopId: String, limit: Int, completion: @escaping Completion<[HistoryItem]>) {
        informationFacade.getAccountHistroy(nameOrID: nameOrID, startId: startId, stopId: stopId, limit: limit, completion: completion)
    }

    // MARK: FeeFacade
    
    public func getFeeForTransferOperation(fromNameOrId: String,
                                           toNameOrId: String,
                                           amount: UInt,
                                           asset: String,
                                           completion: @escaping Completion<AssetAmount>) {
        
        feeFacade.getFeeForTransferOperation(fromNameOrId: fromNameOrId,
                                             toNameOrId: toNameOrId,
                                             amount: amount,
                                             asset: asset,
                                             completion: completion)
    }
    
    // MARK: TransactionFacade
    
    public func sendTransferOperation(fromNameOrId: String,
                                      password: String,
                                      toNameOrId: String,
                                      amount: UInt,
                                      asset: String,
                                      message: String?,
                                      completion: @escaping (Result<Bool, ECHOError>) -> Void) {
        
        transacitonFacade.sendTransferOperation(fromNameOrId: fromNameOrId,
                                                password: password,
                                                toNameOrId: toNameOrId,
                                                amount: amount,
                                                asset: asset,
                                                message: message,
                                                completion: completion)
    }
    
    // MARK: AssetsFacade

    public func createAsset(nameOrId: String,
                            password: String,
                            asset: Asset,
                            completion: @escaping Completion<Bool>) {
        
        assetsFacade.createAsset(nameOrId: nameOrId, password: password, asset: asset, completion: completion)
    }
    
    public func issueAsset(issuerNameOrId: String,
                           password: String,
                           asset: String,
                           amount: UInt,
                           destinationIdOrName: String,
                           message: String?,
                           completion: @escaping Completion<Bool>) {
        
        assetsFacade.issueAsset(issuerNameOrId: issuerNameOrId,
                                password: password,
                                asset: asset,
                                amount: amount,
                                destinationIdOrName: destinationIdOrName,
                                message: message,
                                completion: completion)
    }
    
    public func listAssets(lowerBound: String,
                           limit: Int,
                           completion: @escaping Completion<[Asset]>) {
        
        assetsFacade.listAssets(lowerBound: lowerBound, limit: limit, completion: completion)
    }
    
    public func getAsset(assetIds: [String],
                         completion: @escaping Completion<[Asset]>) {
        
        assetsFacade.getAsset(assetIds: assetIds, completion: completion)
    }

}
