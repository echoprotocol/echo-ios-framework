//
//  SubscriptionFacadeImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 23.07.2018.
//

struct SubscriptionServices {
    var databaseService: DatabaseApiService
}

final class SubscriptionFacadeImp: SubscriptionFacade {
    
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
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrId], shoudSubscribe: true) { [weak self] (result) in
            if let userAccounts = try? result.dematerialize(), let userAccount = userAccounts[nameOrId] {
                self?.removeDelegate(id: userAccount.account.id, delegate: delegate)
            }
        }
    }
    
    func unsubscribeAll() {
        subscribers = [String: NSPointerArray]()
    }
    
    fileprivate func getUserIdAndSetSubscriber(nameOrId: String, delegate: SubscribeAccountDelegate) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrId], shoudSubscribe: true) { [weak self] (result) in
            if let userAccounts = try? result.dematerialize(), let userAccount = userAccounts[nameOrId] {
                self?.addDelegate(id: userAccount.account.id, delegate: delegate)
            }
        }
    }
    
    fileprivate func handleMessage(_ json: [String: Any]) {
        
        guard let notification = (try? JSONSerialization.data(withJSONObject: json, options: []))
            .flatMap({ try? JSONDecoder().decode(ECHONotification.self, from: $0)}) else {
            return
        }
        
        switch notification.params {
        case .array(let array):
            
            if let objectsArray = (array[safe: 1] as? [Any])
                .flatMap({ $0[safe: 0] as? [Any]}) {
                
                var ids = Set<String>()
                
                for object in objectsArray {
                    
                    if let statistic = (object as? [String: Any])
                        .flatMap({ try? JSONSerialization.data(withJSONObject: $0, options: [])})
                        .flatMap({ try? JSONDecoder().decode(Statistics.self, from: $0) }) {
                        
                        ids.insert(statistic.owner)
                    }
                }
                
                getAccountAdnNotify(ids: ids)
            }
        default:
            break
        }
    }
    
    fileprivate func getAccountAdnNotify(ids: Set<String>) {
        
        for id in ids {
            guard let _ = subscribers[id] else {
                continue
            }
            
            services.databaseService.getFullAccount(nameOrIds: [id], shoudSubscribe: true) { [weak self] (result) in
                
                if let userAccounts = try? result.dematerialize(),
                    let userAccount = userAccounts[id] {
                    
                    self?.notifyDelegatesForUser(id: id, userAccount: userAccount)
                }
            }
        }
    }
    
    fileprivate func addDelegate(id: String, delegate: SubscribeAccountDelegate) {
        
        let delegates: NSPointerArray
        
        if let settedDelegates = subscribers[id] {
            delegates = settedDelegates
        } else {
            delegates = NSPointerArray.weakObjects()
        }
        
        delegates.addObject(delegate)
        subscribers[id] = delegates
    }
    
    fileprivate func removeDelegate(id: String, delegate: SubscribeAccountDelegate) {
        
        guard let delegates = subscribers[id] else {
            return
        }
        
        let index = delegates.index(ofAccessibilityElement: delegates)
        delegates.removeObject(at: index)
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
