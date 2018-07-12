//
//  SocketCoreComponent.swift
//  QTUM
//
//  Created by Fedorenko Nikita on 22.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

enum SocketConnectionState {
    case notConnected, connected, connecting, reconnecting, disconnected, connectionFailed
}

protocol SocketCoreComponent {
    
    var state: SocketConnectionState { get }
    var onConnect: (() -> ())? {get set}
    var onDisconnect: (() -> ())? {get set}
    var onFailedConnection: (() -> ())? {get set}
    
    func connect(toUrl: String)
    func disconnect()
    
    func on(event: String, callback: @escaping ([Any]) -> () )
    func emit(event: String, items: [Any])
}
