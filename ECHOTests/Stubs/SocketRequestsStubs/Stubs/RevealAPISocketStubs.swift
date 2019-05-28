//
//  RevealAPISocketStubs.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 06.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct LoginRevealSocketRequestStub: SocketRequestStub {
    
    var operationType = "login"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":true}"
    }
}

struct HistoryAPIRevealSocketRequestStub: SocketRequestStub {
    
    var operationType = "history"

    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":4}"
    }
}

struct DatabaseAPIRevealSocketRequestStub: SocketRequestStub {
    
    var operationType = "database"

    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":2}"
    }
}

struct NetworkBroadcastAPIRevealSocketRequestStub: SocketRequestStub {
    
    var operationType = "network_broadcast"

    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":3}"
    }
}

struct NetworkNodesAPIRevealSocketRequestStub: SocketRequestStub {
    
    var operationType = "network_node"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":6}"
    }
}

struct CryptoAPIRevealSocketRequestStub: SocketRequestStub {
    
    var operationType = "crypto"

    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":5}"
    }
}

struct RegistrationAPIRevealSocketRequestStub: SocketRequestStub {
    
    var operationType = "registration"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":7}"
    }
}
