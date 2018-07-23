//
//  SubscriptionFacadeImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 23.07.2018.
//

struct SubscriptionServices {
    var databaseService: DatabaseApiService
}

class SubscriptionFacadeImp: SubscriptionFacade {
    
    var services: SubscriptionServices
    var socketCore: SocketCoreComponent
    
    var subscribers = [String: SubscribeAccountDelegate]()
    
    init(services: SubscriptionServices,
         socketCore: SocketCoreComponent) {
        self.services = services
        self.socketCore = socketCore
    }
    
    func subscribeToAccount(nameOrId: String, delegate: SubscribeAccountDelegate) {
        
        socketCore.onMessage = { [weak self] (result) in
            self?.handleMessage(result)
        }
        
        services.databaseService.setSubscribeCallback { [weak self] (_) in
            self?.getAccountWithSubscription(nameOrId: nameOrId, delegate: delegate)
        }
    }
    
    func unsubscribeToAccount(nameOrId: String, delegate: SubscribeAccountDelegate) {
        subscribers[nameOrId] = nil
    }
    
    func unsubscribeAll(completion: Completion<Bool>) {
        subscribers = [String: SubscribeAccountDelegate]()
    }
    
    fileprivate func getAccountWithSubscription(nameOrId: String, delegate: SubscribeAccountDelegate) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrId], shoudSubscribe: true) { [weak self] (result) in
            if let userAccount = try? result.dematerialize() {
                self?.subscribers[userAccount.account.id] = delegate
            }
        }
    }
    
    fileprivate func handleMessage(_ json: [String: Any]) {
        
        let result = (json["params"] as? [Any])
            .flatMap { $0[safe: 1] as? [Any]}
            .flatMap { $0[safe: 0] as? [Any]}
            .flatMap { $0[safe: 0] as? [String: Any]}
            .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: []) }
            .flatMap { try? JSONDecoder().decode(Statistics.self, from: $0) }
        
        if let result = result {
            getAccountAndNotify(id: result.owner)
        }
    }
    
    fileprivate func getAccountAndNotify(id: String) {
        
        services.databaseService.getFullAccount(nameOrIds: [id], shoudSubscribe: true) { [weak self] (result) in
            if let userAccount = try? result.dematerialize() {
                let subscriber = self?.subscribers[id]
                subscriber?.didUpdateAccount(userAccount: userAccount)
            }
        }
    }
}
