//
//  SubscriptionFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    The interface of the class that allows you to receive notification about the change account.
 */
public protocol SubscribeAccountDelegate: class {
    func didUpdateAccount(userAccount: UserAccount)
}

/**
    The interface of the class that allows you to receive notification about the change dynamic global properties.
 */
public protocol SubscribeDynamicGlobalPropertiesDelegate: class {
    func didUpdateDynamicGlobalProperties(dynamicGlobalProperties: DynamicGlobalProperties)
}

/**
    The interface of the class that allows you to receive notification about the create new block with his number
 */
public protocol SubscribeBlockDelegate: class {
    func didCreateBlock(block: Block)
}

/**
    The interface of the class that allows you to receive notification about contracts changes
 */
public protocol SubscribeContractsDelegate: class {
    
    func contractUpdated(contract: Contract)
    func contractHistoryCreated(historyObject: ContractHistory)
}

/**
    The interface of the class that allows you to receive notification about the create new logs from specific contract
 */
public protocol SubscribeContractLogsDelegate: class {
    func didCreateLogs(logs: [ContractLogEnum])
}

/**
    A class interface that allows you to track the change to an account
 */
public protocol SubscriptionFacade {
    
/**
     Subscribes to listening chain objects
     
     - Parameter completion: Callback which returns status of subscription
 */
    func setSubscribeCallback(completion: @escaping Completion<Bool>)
    
/**
     Adding a listener to the account change
     
     - Parameter nameOrId: Name or id of the account for which the subscription will be changed
     - Parameter delegate: The class that will receive account notifications
     
     - Remark:
     Delegate must be a class
 */
    func subscribeToAccount(nameOrId: String, delegate: SubscribeAccountDelegate)
    
/**
    Removing a listener to the account change

    - Parameter nameOrId: Name or id of the account for which the subscription will be changed
    - Parameter delegate: The class that receive account notifications
 */
    func unsubscribeToAccount(nameOrId: String, delegate: SubscribeAccountDelegate)
    
/**
     Adding a listener to the dynamic global properties change
     
     - Parameter delegate: The class that receive change notifications
     
     - Remark:
     Delegate must be a class
 */
    func subscribeToDynamicGlobalProperties(delegate: SubscribeDynamicGlobalPropertiesDelegate)
    
/**
     Removing a listener to the dynamic global properties change
 */
    func unsubscribeToDynamicGlobalProperties()
    
/**
     Adding a listener to the block create
     
     - Parameter delegate: The class that receive create notifications
     
     - Remark:
     Delegate must be a class
 */
    func subscribeToBlock(delegate: SubscribeBlockDelegate)
    
/**
     Removing a listener to the block create
 */
    func unsubscribeToBlock()
    
/**
     Adding a listener to contracts changes by contracts ids
     
     - Parameter contractsIds: Ids of the contracts for subscribe
     - Parameter delegate: The class that will receive notifications
     
     - Remark:
     Delegate must be a class
 */
    func subscribeContracts(contractsIds: [String], delegate: SubscribeContractsDelegate)
    
/**
     Removing a listener to the contracts changes
     
     - Parameter contractIds: Ids of the contracts for unsubscribe
     - Parameter delegate: The class that will receive contracts change notifications
 */
    func unsubscribeToContracts(contractIds: [String], delegate: SubscribeContractsDelegate)
    
/**
     Adding a listener to the new contract logs
     
     - Parameter contractId: Id of the contract for which the logs will create
     - Parameter delegate: The class that will receive contract logs notifications
     
     - Remark:
     Delegate must be a class
 */
    func subscribeToContractLogs(contractId: String, delegate: SubscribeContractLogsDelegate)
    
/**
     Removing a listener to the new contract logs
     
     - Parameter contractId: Id of the contract for which the logs will create
     - Parameter delegate: The class that will receive contract logs notifications
 */
    func unsubscribeToContractLogs(contractId: String, delegate: SubscribeContractLogsDelegate)
    
/**
     Removing all listeners to the account change
 */
    func unsubscribeAll()
}
