//
//  SocketCoreComponent.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 28.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    A class that configures and passes operations through a socket.
 */
public protocol SocketCoreComponent: class {
    
    init(messanger: SocketMessenger,
         url: String,
         noticeUpdateHandler: NoticeActionHandler?,
         socketQueue: DispatchQueue)
    
    func connect(options: APIOption, completion: @escaping Completion<Bool>)
    func disconnect()
    func send(operation: SocketOperation)
    func nextOperationId() -> Int
}
