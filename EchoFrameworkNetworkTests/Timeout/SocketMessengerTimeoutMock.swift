//
//  SocketMessengerTimeoutMock.swift
//  ECHONetworkTests
//
//  Created by Vladimir Sharaev on 11.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

@testable import EchoFramework

class SocketMessengerTimeoutMock: SocketMessengerImp {
    
    var simulatePackageLost = false
    
    override func write(_ string: String) {
        if !simulatePackageLost {
            super.write(string)
        }
    }
    
    func simulateDisconnect() {
        onDisconnect?()
    }
    
    func simulateNonResponces() {
        socket?.onText = nil
    }
}
