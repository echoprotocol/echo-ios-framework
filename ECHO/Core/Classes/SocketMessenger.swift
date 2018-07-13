//
//  File.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 12.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

protocol SocketCoreComponent {
    
    init(messanger: SocketMessenger, url: String)
    func connect(options: APIOption, completion: @escaping Completion<Bool>)
    func disconnect()
    func send(operation: SocketOperation)
}

class SocketCoreComponentImp: SocketCoreComponent {
    
    var messenger: SocketMessenger
    let url: String
    
    required init(messanger: SocketMessenger, url: String) {
        self.messenger = messanger
        self.url = url
    }
    
    func connect(options: APIOption, completion: @escaping Completion<Bool>) {
        
        messenger.onConnect = { 
            let result = Result<Bool, ECHOError>(value: true)
            completion(result)
        }
        
        messenger.onFailedConnection = {
            let error = Result<Bool, ECHOError>(error: ECHOError.undefined)
            completion(error)
        }
        
        messenger.connect(toUrl: url)
        
        messenger.on(event: "") { (result) in
            print(result)
        }
    }
    
    func disconnect() {
        messenger.disconnect()
    }
    
    func send(operation: SocketOperation) {
        
        guard let jsonString: String = operation.toJSON() else {
            return
        }
        
        messenger.emit(event: jsonString, items: [])
    }
}
