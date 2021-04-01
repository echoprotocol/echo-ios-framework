//
//  SubscribeAccountDelegateStub.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 28/03/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

@testable import EchoFramework

class SubscribeAccountDelegateStub: SubscribeAccountDelegate {
    
    var subscribeNameOrIds = [String]()
    var delegateEvents = 0
    var rightDelegateEvents = 0
    
    func didUpdateAccount(userAccount: UserAccount) {
        
        delegateEvents += 1
        
        if let _ = subscribeNameOrIds.first(where: {userAccount.account.id == $0 && userAccount.account.name == $0 }) {
            rightDelegateEvents += 1
        }
    }
    
    func addSubscribe(nameOrId: String) {
        subscribeNameOrIds.append(nameOrId)
    }
}
