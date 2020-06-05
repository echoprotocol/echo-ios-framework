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
    let noticeUpdateHandler: NoticeActionHandler?
    let timeout: TimeInterval
    var debug: Bool
    var operationsMap = [Int: SocketOperation]()
    var operationsTimes = [(TimeInterval, SocketOperation)]()
    var currentOperationId: Int = 0
    
    var workingQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    required init(messanger: SocketMessenger, url: String,
                  noticeUpdateHandler: NoticeActionHandler?,
                  socketQueue: DispatchQueue,
                  timeout: TimeInterval,
                  debug: Bool) {
        self.messenger = messanger
        self.messenger.callbackQueue = socketQueue
        self.url = url
        self.noticeUpdateHandler = noticeUpdateHandler
        self.timeout = timeout
        self.debug = debug
        
        monitorTimeouts()
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
        
        messenger.onDisconnect = { [weak self] in
            let result = Result<Bool, ECHOError>(error: ECHOError.connectionLost)
            completion(result)
            
            self?.forceEndAllOperations()
            self?.noticeUpdateHandler?.actionAllNoticesLost()
        }
        
        messenger.onText = { [weak self] (result) in
            self?.workingQueue.addOperation { [weak self] in
                self?.handleMessage(result)
            }
        }
        
        messenger.onFailedConnect = { [weak self] in
            let result = Result<Bool, ECHOError>(error: ECHOError.invalidUrl)
            completion(result)
            
            self?.forceEndAllOperations()
            self?.noticeUpdateHandler?.actionAllNoticesLost()
        }
        
        messenger.connect(toUrl: url)
    }
    
    func disconnect() {
        messenger.disconnect()
        forceEndAllOperations()
        noticeUpdateHandler?.actionAllNoticesLost()
        currentOperationId = 0
    }
    
    func send(operation: SocketOperation) {
        
        workingQueue.addOperation { [weak self] in
            guard let jsonString: String = operation.toJSON() else {
                return
            }
            
            guard self?.messenger.state == .connected else {
                operation.forceEnd(error: .connectionLost)
                return
            }
            
            self?.operationsMap[operation.operationId] = operation
            self?.addOperationToTimeoutMap(operation)
            self?.debug(jsonString)
            self?.messenger.write(jsonString)
        }
    }
    
    fileprivate func handleMessage(_ string: String) {
        
        debug(
            """
            ------------
            \(string)
            ----------
            """
        )
        
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
        operationsTimes.removeAll(where: { $0.1.operationId == id })
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
            operation.forceEnd(error: .connectionLost)
        }
        operationsMap = [Int: SocketOperation]()
        operationsTimes = [(TimeInterval, SocketOperation)]()
    }
    
    fileprivate func monitorTimeouts() {
        workingQueue.addOperation { [weak self] in
            guard let self = self else {
                return
            }
            
            let time = Date().timeIntervalSince1970 - self.timeout
            
            var removedCount = 0
            for index in 0..<self.operationsTimes.count {
                let timeWithOperation = self.operationsTimes[index]
                let opTime = timeWithOperation.0
                let operation = timeWithOperation.1
                if opTime > time {
                    break
                }
                
                operation.forceEnd(error: .timeout)
                self.operationsMap[operation.operationId] = nil
                removedCount += 1
            }
            
            self.operationsTimes.removeFirst(removedCount)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(timeout))) { [weak self] in
            self?.monitorTimeouts()
        }
    }
    
    private func addOperationToTimeoutMap(_ operation: SocketOperation) {
        let currentTime = Date().timeIntervalSince1970
        operationsTimes.append((currentTime, operation))
    }
    
    private func debug(_ line: String) {
        if debug {
            print(line)
        }
    }
}
