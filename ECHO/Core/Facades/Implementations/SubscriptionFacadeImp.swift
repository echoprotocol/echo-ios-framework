//
//  SubscriptionFacadeImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 23.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct SubscriptionServices {
    var databaseService: DatabaseApiService
}

/**
    Implementation of [SubscriptionFacade](SubscriptionFacade), [ECHOQueueble](ECHOQueueble)
 */
final public class SubscriptionFacadeImp: SubscriptionFacade {
    
    let services: SubscriptionServices
    let socketCore: SocketCoreComponent
    var subscribers = [String: NSPointerArray]()
    weak var dynamicGlobalPropertiesSubscriber: SubscribeDynamicGlobalPropertiesDelegate?
    weak var createBlockSubscriber: SubscribeBlockDelegate?
    
    init(services: SubscriptionServices,
         socketCore: SocketCoreComponent) {
        self.services = services
        self.socketCore = socketCore
    }
    
    public func subscribeToAccount(nameOrId: String, delegate: SubscribeAccountDelegate) {
        
        updateSocketOnDelegate()
        
        services.databaseService.setSubscribeCallback { [weak self] (_) in
            self?.getUserIdAndSetSubscriber(nameOrId: nameOrId, delegate: delegate)
        }
    }
    
    public func unsubscribeToAccount(nameOrId: String, delegate: SubscribeAccountDelegate) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrId], shoudSubscribe: true) { [weak self] (result) in
            if let userAccounts = try? result.dematerialize(), let userAccount = userAccounts[nameOrId] {
                self?.removeDelegate(id: userAccount.account.id, delegate: delegate)
            }
        }
    }
    
    public func subscribeToDynamicGlobalProperties(delegate: SubscribeDynamicGlobalPropertiesDelegate) {
        
        updateSocketOnDelegate()
        
        services.databaseService.setSubscribeCallback { [weak self] (_) in
            self?.getDynamicGlobalPropertiesAndSetSubscriber(delegate: delegate)
        }
    }
    
    public func unsubscribeToDynamicGlobalProperties() {
        dynamicGlobalPropertiesSubscriber = nil
    }
    
    public func subscribeToBlock(delegate: SubscribeBlockDelegate) {
        
        updateSocketOnDelegate()
        
        services.databaseService.setSubscribeCallback { [weak self] (_) in
            self?.getDynamicGlobalPropertiesAndSetSubscriber(delegate: delegate)
        }
    }
    
    public func unsubscribeToBlock() {
        createBlockSubscriber = nil
    }
    
    public func unsubscribeAll() {
        subscribers = [String: NSPointerArray]()
    }
    
    fileprivate func updateSocketOnDelegate() {
        
        socketCore.subscribeToNotifications(subscriver: self)
    }
    
    fileprivate func getUserIdAndSetSubscriber(nameOrId: String, delegate: SubscribeAccountDelegate) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrId], shoudSubscribe: true) { [weak self] (result) in
            if let userAccounts = try? result.dematerialize(), let userAccount = userAccounts[nameOrId] {
                self?.addDelegate(id: userAccount.account.id, delegate: delegate)
            }
        }
    }
    
    fileprivate func getDynamicGlobalPropertiesAndSetSubscriber(delegate: SubscribeDynamicGlobalPropertiesDelegate) {
        
        services.databaseService.getObjects(type: DynamicGlobalProperties.self,
                                            objectsIds: [DynamicGlobalProperties.defaultIdentifier]) { [weak self] (_) in
            self?.dynamicGlobalPropertiesSubscriber = delegate
        }
    }
    
    fileprivate func getDynamicGlobalPropertiesAndSetSubscriber(delegate: SubscribeBlockDelegate) {
        
        services.databaseService.getObjects(type: DynamicGlobalProperties.self,
                                            objectsIds: [DynamicGlobalProperties.defaultIdentifier]) { [weak self] (_) in
            self?.createBlockSubscriber = delegate
        }
    }
    
    fileprivate func handleNotification(_ notification: ECHONotification) {
        
        switch notification.params {
        case .array(let array):
            
            if let objectsArray = (array[safe: 1] as? [Any])
                .flatMap({ $0[safe: 0] as? [Any]}) {
                
                var userIds = Set<String>()
                var dynamicGlobalProperties: DynamicGlobalProperties?
                
                for object in objectsArray {
                    
                    if let userId = findUserId(object: object) {
                        userIds.insert(userId)
                    }
                    
                    dynamicGlobalProperties = findDynamicGlobalPropeties(object: object)
                }
                
                getAccountAndNotify(ids: userIds)
                getBlockIfNeededAndNotify(dynamicGlobalProperties: dynamicGlobalProperties)
            }
        default:
            break
        }
    }
    
    fileprivate func findUserId(object: Any) -> String? {
        
        if let statistic = (object as? [String: Any])
            .flatMap({ try? JSONSerialization.data(withJSONObject: $0, options: [])})
            .flatMap({ try? JSONDecoder().decode(Statistics.self, from: $0) }) {
            
            return statistic.owner
        }
        
        return nil
    }
    
    fileprivate func findDynamicGlobalPropeties(object: Any) -> DynamicGlobalProperties? {
        
        if let globalProperties = (object as? [String: Any])
            .flatMap({ try? JSONSerialization.data(withJSONObject: $0, options: [])})
            .flatMap({ try? JSONDecoder().decode(DynamicGlobalProperties.self, from: $0) }) {
            
            return globalProperties
        }
        
        return nil
    }
    
    fileprivate func getAccountAndNotify(ids: Set<String>) {
        
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
    
    fileprivate func getBlockIfNeededAndNotify(dynamicGlobalProperties: DynamicGlobalProperties?) {
        
        guard let globalProperties = dynamicGlobalProperties else {
            return
        }
        
        dynamicGlobalPropertiesSubscriber?.didUpdateDynamicGlobalProperties(dynamicGlobalProperties: globalProperties)
        
        guard let createBlockSubscriber = createBlockSubscriber else {
            return
        }
        
        services.databaseService.getBlock(blockNumber: globalProperties.headBlockNumber) { (result) in
            
            if let block = try? result.dematerialize() {
                createBlockSubscriber.didCreateBlock(block: block)
            }
        }
    }
}

extension SubscriptionFacadeImp: SubscribeBlockchainNotification {
    
    public func didReceiveNotification(notification: ECHONotification) {
        handleNotification(notification)
    }
}
