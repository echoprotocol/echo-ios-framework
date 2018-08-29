//
//  SubscriptionFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public protocol SubscribeAccountDelegate: class {
    func didUpdateAccount(userAccount: UserAccount)
}

public protocol SubscriptionFacade {
    func subscribeToAccount(nameOrId: String, delegate: SubscribeAccountDelegate)
    func unsubscribeToAccount(nameOrId: String, delegate: SubscribeAccountDelegate)
    func unsubscribeAll()
}
