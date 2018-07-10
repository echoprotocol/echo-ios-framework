//
//  SubscriptionFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

protocol SubscriptionFacade {
    func subscribeToAccount(nameOrId: String, delegate: Any)
    func unsubscribeToAccount(nameOrId: String, delegate: Any)
    func unsubscribeAll(completion: Completion<Bool>)
}
