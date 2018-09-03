//
//  File.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 12.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

final class SocketCoreComponentImp: SocketCoreComponent {
    
    let messenger: SocketMessenger
    let url: String
    var operationsMap = [Int: SocketOperation]()
    var currentOperationId: Int = 0
    var onMessage: (([String: Any]) -> ())?
    
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
        
        messenger.onDisconnect = {
            let result = Result<Bool, ECHOError>(error: ECHOError.connectionLost)
            completion(result)
        }
        
        messenger.onText = { [weak self] (result) in
            
            self?.handleMessage(result)
        }
        
        messenger.onFailedConnect = {
            let result = Result<Bool, ECHOError>(error: ECHOError.invalidUrl)
            completion(result)
        }
        
        messenger.connect(toUrl: url)
    }
    
    func disconnect() {
        messenger.disconnect()
    }
    
    func send(operation: SocketOperation) {
        
        guard let jsonString: String = operation.toJSON() else {
            return
        }
        
        guard messenger.state == .connected else {
            operation.forceEnd()
            return
        }
        
        operationsMap[operation.operationId] = operation
        messenger.write(jsonString)
    }
    
    fileprivate func handleMessage(_ string: String) {
                        
        guard let json = converToJSON(string) else {
            return
        }
        
        onMessage?(json)
        
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
    
    fileprivate func forceEndAllOperations() {
        
        operationsMap.forEach { (_, operation) in
            operation.forceEnd()
        }
        operationsMap = [Int: SocketOperation]()
    }
}
