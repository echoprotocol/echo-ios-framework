//
//  File.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 12.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Implementation of [SocketCoreComponent](SocketCoreComponent)
*/
final class SocketCoreComponentImp: SocketCoreComponent {
    
    let messenger: SocketMessenger
    let url: String
    var operationsMap = [Int: SocketOperation]()
    var currentOperationId: Int = 0
    let noticeUpdateHandler: NoticeActionHandler?
    
    var workingQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    required init(messanger: SocketMessenger, url: String,
                  noticeUpdateHandler: NoticeActionHandler?, socketQueue: DispatchQueue) {
        self.messenger = messanger
        self.messenger.callbackQueue = socketQueue
        self.url = url
        self.noticeUpdateHandler = noticeUpdateHandler
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
            self?.workingQueue.addOperation { [weak self] in
                self?.handleMessage(result)
            }
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
        
        workingQueue.addOperation { [weak self] in
            guard let jsonString: String = operation.toJSON() else {
                return
            }
            
            guard self?.messenger.state == .connected else {
                operation.forceEnd()
                return
            }
            
            self?.operationsMap[operation.operationId] = operation
            self?.messenger.write(jsonString)
        }
    }
    
    fileprivate func handleMessage(_ string: String) {
        
        print("""
            ------------
            \(string)
            ----------
            """)
        
        guard let json = converToJSON(string),
            let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
                return
        }
        
        if let response = decodeDirectResopnse(data: data) {
            
            handleResponse(response)
        } else if let notifcation = decodeNotice(data: data) {
            
            handleNotification(notifcation)
        }
    }
    
    fileprivate func handleResponse(_ response: ECHODirectResponse) {
        
        let id = response.id
        guard let operation = operationsMap[id] else {
            return
        }
        
        operation.handleResponse(response)
        operationsMap[id] = nil
    }
    
    fileprivate func handleNotification(_ notification: ECHONotification) {
        
        guard let noticeUpdateHandler = noticeUpdateHandler else {
            return
        }
        
        noticeUpdateHandler.actionReceiveNotice(notification: notification)
    }
    
    fileprivate func decodeDirectResopnse(data: Data) -> ECHODirectResponse? {
        
        guard let response = try? JSONDecoder().decode(ECHODirectResponse.self, from: data) else {
            return nil
        }
        return response
    }
    
    fileprivate func decodeNotice(data: Data) -> ECHONotification? {
        
        guard let notification = try? JSONDecoder().decode(ECHONotification.self, from: data) else {
            return nil
        }
        return notification
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
