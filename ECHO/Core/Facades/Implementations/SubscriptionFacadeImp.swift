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
    var accountSubscribers = [String: NSPointerArray]()
    var contractsSubscribers = [String: NSPointerArray]()
    var contractLogsSubscribers = [String: NSPointerArray]()
    
    weak var dynamicGlobalPropertiesSubscriber: SubscribeDynamicGlobalPropertiesDelegate?
    weak var createBlockSubscriber: SubscribeBlockDelegate?
    
    init(services: SubscriptionServices,
         noticeDelegateHandler: NoticeEventDelegateHandler) {
        
        self.services = services
        noticeDelegateHandler.delegate = self
    }
    
    public func setSubscribeCallback(completion: @escaping Completion<Bool>) {
        
        services.databaseService.setSubscribeCallback(completion: completion)
    }
    
    public func subscribeToAccount(nameOrId: String, delegate: SubscribeAccountDelegate) {
        
        getUserIdAndSetSubscriber(nameOrId: nameOrId, delegate: delegate)
    }
    
    public func unsubscribeToAccount(nameOrId: String, delegate: SubscribeAccountDelegate) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrId], shoudSubscribe: false) { [weak self] (result) in
            if let userAccounts = try? result.dematerialize(), let userAccount = userAccounts[nameOrId] {
                self?.removeAccountDelegate(id: userAccount.account.id, delegate: delegate)
            }
        }
    }
    
    public func subscribeToDynamicGlobalProperties(delegate: SubscribeDynamicGlobalPropertiesDelegate) {
        
        getDynamicGlobalPropertiesAndSetSubscriber(delegate: delegate)
    }
    
    public func unsubscribeToDynamicGlobalProperties() {
        
        dynamicGlobalPropertiesSubscriber = nil
    }
    
    public func subscribeToBlock(delegate: SubscribeBlockDelegate) {
        
        getDynamicGlobalPropertiesAndSetSubscriber(delegate: delegate)
    }
    
    public func unsubscribeToBlock() {
        
        createBlockSubscriber = nil
    }
    
    public func subscribeContracts(contractsIds: [String], delegate: SubscribeContractsDelegate) {
        
        services.databaseService.subscribeContracts(contractsIds: contractsIds) { [weak self] (result) in
            if let boolResult = try? result.dematerialize(),
                boolResult {
                self?.addContractsDelegate(ids: contractsIds, delegate: delegate)
            }
        }
    }
    
    public func unsubscribeToContracts(contractIds: [String], delegate: SubscribeContractsDelegate) {
        
        removeContractsDelegate(ids: contractIds, delegate: delegate)
    }
    
    public func subscribeToContractLogs(contractId: String, delegate: SubscribeContractLogsDelegate) {
        
        getSubscribeToContractLogsAndSetSubscriber(contractId: contractId, delegate: delegate)
    }
    
    public func unsubscribeToContractLogs(contractId: String, delegate: SubscribeContractLogsDelegate) {
        
        removeContractLogsDelegate(id: contractId, delegate: delegate)
    }
    
    public func unsubscribeAll() {
        
        accountSubscribers = [String: NSPointerArray]()
        contractsSubscribers = [String: NSPointerArray]()
        contractLogsSubscribers = [String: NSPointerArray]()
        dynamicGlobalPropertiesSubscriber = nil
        createBlockSubscriber = nil
    }
    
    fileprivate func getUserIdAndSetSubscriber(nameOrId: String, delegate: SubscribeAccountDelegate) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrId], shoudSubscribe: true) { [weak self] (result) in
            if let userAccounts = try? result.dematerialize(),
                let userAccount = userAccounts[nameOrId] {
                self?.addAccountDelegate(id: userAccount.account.id, delegate: delegate)
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
    
    fileprivate func getSubscribeToContractLogsAndSetSubscriber(contractId: String, delegate: SubscribeContractLogsDelegate) {
        
        services.databaseService.subscribeContractLogs(contractId: contractId, fromBlock: 0, toBlock: 0) { [weak self] (_) in
            
            self?.addContractLogsDelegate(id: contractId, delegate: delegate)
        }
    }
    
    fileprivate func handleNotification(_ notification: ECHONotification) {
        
        switch notification.params {
        case .array(let array):
            
            if let objectsArray = (array[safe: 1] as? [Any])
                .flatMap({ $0[safe: 0] as? [Any]}) {
                
                var userIds = Set<String>()
                var dynamicGlobalProperties: DynamicGlobalProperties?
                var contractsLogs = [String: [ContractLog]]()
                var contracts = [String: Contract]()
                var contractsHistory = [ContractHistory]()
                
                for object in objectsArray {
                    
                    // Find user changes
                    if let userId = findUserId(object: object) {
                        userIds.insert(userId)
                    }
                    
                    // Find dynamic global properties changes
                    if let findedDynamicGlobalProperties = findDynamicGlobalPropeties(object: object) {
                        dynamicGlobalProperties = findedDynamicGlobalProperties
                    }
                    
                    // Find contract
                    if let contract = findContracts(object: object) {
                        contracts[contract.id] = contract
                    }
                    
                    // Find contract history
                    if let contractHistory = findContractsHistory(object: object) {
                        contractsHistory.append(contractHistory)
                    }
                    
                    // Find contracts logs
                    if let contractIdAndLog = findContractLogs(object: object) {
                        if var logs = contractsLogs[contractIdAndLog.contractId] {
                            logs.append(contractIdAndLog.log)
                            contractsLogs[contractIdAndLog.contractId] = logs
                        } else {
                            contractsLogs[contractIdAndLog.contractId] = [contractIdAndLog.log]
                        }
                    }
                }
                
                getAccountAndNotify(ids: userIds)
                getBlockIfNeededAndNotify(dynamicGlobalProperties: dynamicGlobalProperties)
                notifyContracts(contracts: contracts, histories: contractsHistory)
                notifyContractLogsCreated(contractsMap: contractsLogs)
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
    
    fileprivate func findContracts(object: Any) -> Contract? {
        
        if let contract = (object as? [String: Any])
            .flatMap({ try? JSONSerialization.data(withJSONObject: $0, options: [])})
            .flatMap({ try? JSONDecoder().decode(Contract.self, from: $0) }) {
            
            return contract
        }
        
        return nil
    }
    
    fileprivate func findContractsHistory(object: Any) -> ContractHistory? {
        
        if let contract = (object as? [String: Any])
            .flatMap({ try? JSONSerialization.data(withJSONObject: $0, options: [])})
            .flatMap({ try? JSONDecoder().decode(ContractHistory.self, from: $0) }) {
            
            return contract
        }
        
        return nil
    }
    
    fileprivate func findContractLogs(object: Any) -> (contractId: String, log: ContractLog)? {
        
        if let log = (object as? [String: Any])
            .flatMap({ try? JSONSerialization.data(withJSONObject: $0, options: [])})
            .flatMap({ try? JSONDecoder().decode(ContractLog.self, from: $0) }) {
            
            let interpretator = AbiArgumentCoderImp()
            let type = AbiParameterType.contractAddress
            let outputs = [AbiFunctionEntries(name: "", typeString: type.description, type: type)]
            
            let values = try? interpretator.getValueTypes(string: log.address, outputs: outputs)
            
            guard let contractIdLastPart = values?[safe: 0]?.value as? String else {
                return nil
            }
            
            let idString = ObjectType.contract.getFullObjectIdByLastPart(contractIdLastPart)
            
            return (idString, log)
        }
        
        return nil
    }
    
    fileprivate func getAccountAndNotify(ids: Set<String>) {
        
        for id in ids {
            guard let _ = accountSubscribers[id] else {
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
    
    fileprivate func addAccountDelegate(id: String, delegate: SubscribeAccountDelegate) {
        
        let delegates: NSPointerArray
        
        if let settedDelegates = accountSubscribers[id] {
            delegates = settedDelegates
        } else {
            delegates = NSPointerArray.weakObjects()
        }
        
        delegates.addObject(delegate)
        accountSubscribers[id] = delegates
    }
    
    fileprivate func addContractsDelegate(ids: [String], delegate: SubscribeContractsDelegate) {
        
        for id in ids {
            let delegates: NSPointerArray
            
            if let settedDelegates = contractsSubscribers[id] {
                delegates = settedDelegates
            } else {
                delegates = NSPointerArray.weakObjects()
            }
            
            delegates.addObject(delegate)
            contractsSubscribers[id] = delegates
        }
    }
    
    fileprivate func addContractLogsDelegate(id: String, delegate: SubscribeContractLogsDelegate) {
        
        let delegates: NSPointerArray
        
        if let settedDelegates = contractLogsSubscribers[id] {
            delegates = settedDelegates
        } else {
            delegates = NSPointerArray.weakObjects()
        }
        
        delegates.addObject(delegate)
        contractLogsSubscribers[id] = delegates
    }
    
    fileprivate func removeAccountDelegate(id: String, delegate: SubscribeAccountDelegate) {
        
        guard let delegates = accountSubscribers[id] else {
            return
        }
        
        let index = delegates.index(ofAccessibilityElement: delegates)
        delegates.removeObject(at: index)
        accountSubscribers[id] = delegates
    }
    
    fileprivate func removeContractsDelegate(ids: [String], delegate: SubscribeContractsDelegate) {
        
        for id in ids {
            guard let delegates = contractsSubscribers[id] else {
                return
            }
            
            let index = delegates.index(ofAccessibilityElement: delegates)
            delegates.removeObject(at: index)
            contractsSubscribers[id] = delegates
        }
    }
    
    fileprivate func removeContractLogsDelegate(id: String, delegate: SubscribeContractLogsDelegate) {
        
        guard let delegates = contractLogsSubscribers[id] else {
            return
        }
        
        let index = delegates.index(ofAccessibilityElement: delegates)
        delegates.removeObject(at: index)
        contractLogsSubscribers[id] = delegates
    }
    
    fileprivate func notifyDelegatesForUser(id: String, userAccount: UserAccount) {
        
        guard let delegates = accountSubscribers[id] else {
            return
        }
       
        delegates.compact()
        
        for index in 0..<delegates.count {
            
            if let delegate = delegates.object(at: index) as? SubscribeAccountDelegate {
                delegate.didUpdateAccount(userAccount: userAccount)
            }
        }
    }
    
    fileprivate func notifyContracts(contracts: [String: Contract], histories: [ContractHistory]) {
        
        for identifier in contracts.keys {
            
            guard let delegates = contractsSubscribers[identifier],
                let contract = contracts[identifier] else {
                continue
            }
            
            for index in 0..<delegates.count {
                if let delegate = delegates.object(at: index) as? SubscribeContractsDelegate {
                    delegate.contractUpdated(contract: contract)
                }
            }
        }
        
        for history in histories {
            guard let delegates = contractsSubscribers[history.contract.id] else {
                continue
            }
            
            for index in 0..<delegates.count {
                if let delegate = delegates.object(at: index) as? SubscribeContractsDelegate {
                    delegate.contractHistoryCreated(historyObject: history)
                }
            }
        }
    }
    
    fileprivate func notifyContractLogsCreated(contractsMap: [String: [ContractLog]]) {
        
        for contractId in contractsMap.keys {
            guard let logs = contractsMap[contractId] else {
                continue
            }
            notifyDelegatesForContract(id: contractId, logs: logs)
        }
    }
    
    fileprivate func notifyDelegatesForContract(id: String, logs: [ContractLog]) {
        
        guard let delegates = contractLogsSubscribers[id] else {
            return
        }
        
        delegates.compact()
        
        for index in 0..<delegates.count {
            
            if let delegate = delegates.object(at: index) as? SubscribeContractLogsDelegate {
                delegate.didCreateLogs(logs: logs)
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

extension SubscriptionFacadeImp: NoticeEventDelegate {
    
    public func didReceiveNotification(notification: ECHONotification) {
        handleNotification(notification)
    }
}
