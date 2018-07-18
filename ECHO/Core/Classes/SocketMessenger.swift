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
    func nextOperationId() -> Int
}

class SocketCoreComponentImp: SocketCoreComponent {
    
    var messenger: SocketMessenger
    let url: String
    var operationsMap = [Int: SocketOperation]()
    var currentOperationId: Int = 0
    
    required init(messanger: SocketMessenger, url: String) {
        self.messenger = messanger
        self.url = url
    }
    
    func nextOperationId() -> Int {
        currentOperationId += 1
        return  currentOperationId
    }
    
    func connect(options: APIOption, completion: @escaping Completion<Bool>) {
        
        messenger.onConnect = { 
            let result = Result<Bool, ECHOError>(value: true)
            completion(result)
        }
        
        messenger.connect(toUrl: url)
        
        messenger.onText = { [weak self] (result) in
            
            self?.handleMessage(result)
        }
    }
    
    func disconnect() {
        messenger.disconnect()
    }
    
    func send(operation: SocketOperation) {
        
        guard let jsonString: String = operation.toJSON() else {
            return
        }
        
        operationsMap[operation.operationId] = operation
        messenger.write(jsonString)
    }
    
    fileprivate func handleMessage(_ string: String) {
        
        guard let json = converToJSON(string) else {
            return
        }
        
        guard let operationId = json["id"] as? Int else {
            return
        }
        
        guard let operation = operationsMap[operationId] else {
            return
        }
        
        operation.complete(json: json)
        operationsMap[operationId] = nil
    }
    
    fileprivate func converToJSON(_ jsonString: String) -> [String: Any]? {
        
        let json = (jsonString.data(using: .utf8))
            .flatMap { try? JSONSerialization.jsonObject(with: $0, options: [])}
        
        return json as? [String: Any]
    }
}
