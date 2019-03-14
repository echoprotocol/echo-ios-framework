//
//  RevealAPISocketStubs.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 06.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct LoginRevealSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "login"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":true}"
    }
}

struct HistoryAPIRevealSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "history"

    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":4}"
    }
}

struct DatabaseAPIRevealSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "database"

    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":2}"
    }
}

struct NetworkBroadcastAPIRevealSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "network_broadcast"

    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":3}"
    }
}

struct NetworkNodesAPIRevealSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "network_node"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":6}"
    }
}

struct CryptoAPIRevealSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "crypto"

    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":5}"
    }
}

struct RegistrationAPIRevealSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "registration"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":7}"
    }
}

struct RevialAPISocketRequestStubHodler: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [LoginRevealSocketRequestElementStub(),
                                         HistoryAPIRevealSocketRequestElementStub(),
                                         DatabaseAPIRevealSocketRequestElementStub(),
                                         NetworkBroadcastAPIRevealSocketRequestElementStub(),
                                         NetworkNodesAPIRevealSocketRequestElementStub(),
                                         CryptoAPIRevealSocketRequestElementStub(),
                                         RegistrationAPIRevealSocketRequestElementStub()]
}
