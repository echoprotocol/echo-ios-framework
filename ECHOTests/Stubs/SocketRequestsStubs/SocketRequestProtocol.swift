//
//  SocketRequestProtocol.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 06.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

protocol SocketRequestStub {
    
    var operationType: String { get set }
    
    func response(id: Int, operationType: String) -> String?
    func createResponce(id: Int) -> String
}

extension SocketRequestStub {
    
    func response(id: Int, operationType: String) -> String? {
        
        if operationType == self.operationType {
            return createResponce(id: id)
        }
        return nil
    }
}

protocol SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] { get set }
    
    func response(id: Int, operationType: String) -> String?
}

extension SocketRequestStubHodler {
    
    func response(id: Int, operationType: String) -> String? {
        
        for request in requests {
            
            if request.operationType == operationType {
                return request.createResponce(id: id)
            }
        }
        
        return nil
    }
}

