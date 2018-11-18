//
//  SocketCoreComponent.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 28.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
 The interface of the class that allows you to receive notification from blockchain.
 */
protocol SubscribeBlockchainNotification: class {
    func didReceiveNotification(notification: ECHONotification)
}

/**
    A class that configures and passes operations through a socket.
 */
protocol SocketCoreComponent: class {
    
    init(messanger: SocketMessenger, url: String)
    
    func connect(options: APIOption, completion: @escaping Completion<Bool>)
    func disconnect()
    func send(operation: SocketOperation)
    func nextOperationId() -> Int
    
    func subscribeToNotifications(subscriver: SubscribeBlockchainNotification)
}
