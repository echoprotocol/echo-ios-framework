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
    A class interface that allows you to track the change to an account
 */
public protocol SubscriptionFacade {
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
     Removing all listeners to the account change
 */
    func unsubscribeAll()
}
