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
    
    let services: SubscriptionServices
    let socketCore: SocketCoreComponent
    var subscribers = [String: NSPointerArray]()
    
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
            self?.getUserIdAndSetSubscriber(nameOrId: nameOrId, delegate: delegate)
        }
    }
    
    func unsubscribeToAccount(nameOrId: String, delegate: SubscribeAccountDelegate) {
        subscribers[nameOrId] = NSPointerArray()
    }
    
    func unsubscribeAll(completion: Completion<Bool>) {
        subscribers = [String: NSPointerArray]()
    }
    
    fileprivate func getUserIdAndSetSubscriber(nameOrId: String, delegate: SubscribeAccountDelegate) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrId], shoudSubscribe: true) { [weak self] (result) in
            if let userAccount = try? result.dematerialize() {
                self?.addDelegate(id: userAccount.account.id, delegate: delegate)
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
            getAccountAdnNotify(id: result.owner)
        }
    }
    
    fileprivate func getAccountAdnNotify(id: String) {
        
        services.databaseService.getFullAccount(nameOrIds: [id], shoudSubscribe: true) { [weak self] (result) in
            if let userAccount = try? result.dematerialize() {
                self?.notifyDelegatesForUser(id: id, userAccount: userAccount)
            }
        }
    }
    
    fileprivate func addDelegate(id: String, delegate: SubscribeAccountDelegate) {
        
        let delegates: NSPointerArray
        
        if let settedDelegates = subscribers[id] {
            delegates = settedDelegates
        } else {
            delegates = NSPointerArray()
        }
        
        delegates.addObject(delegate)
        subscribers[id] = delegates
    }
    
    fileprivate func notifyDelegatesForUser(id: String, userAccount: UserAccount) {
        
        guard let delegates = subscribers[id] else {
            return
        }
       
        delegates.compact()
        
        for index in 0..<delegates.count {
            
            if let delegate = delegates.object(at: index) as? SubscribeAccountDelegate {
                delegate.didUpdateAccount(userAccount: userAccount)
            }
        }
    }
}
