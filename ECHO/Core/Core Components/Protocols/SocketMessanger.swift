//
//  SocketCoreComponent.swift
//  QTUM
//
//  Created by Fedorenko Nikita on 22.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

public enum SocketConnectionState {
    case notConnected, connected, connecting, reconnecting, disconnected, connectionFailed
}

public protocol SocketMessenger: class {
    
    var state: SocketConnectionState { get }
    var onConnect: (() -> ())? { get set }
    var onDisconnect: (() -> ())? { get set }
    var onText: ((String) -> ())? { get set }
    
    func connect(toUrl: String)
    func disconnect()
    
    func write(_ string: String)
}
