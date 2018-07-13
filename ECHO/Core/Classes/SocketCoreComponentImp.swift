//
//  SocketCoreComponentImp.swift
//  QTUM
//
//  Created by Fedorenko Nikita on 26.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation
import SocketIO

final class SocketMessengerImp: SocketMessenger {
    
    var state: SocketConnectionState = .notConnected
    var onConnect: (() -> ())?
    var onReconnect: (() -> ())?
    var onDisconnect: (() -> ())?
    var onFailedConnection: (() -> ())?
    
    var timeout: Double = 3
    
    var manager: SocketManager?
    
    var socket: SocketIOClient? {
        return manager?.defaultSocket
    }
    
    var workingQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    func connect(toUrl: String) {
        
        let operation: BlockOperation = BlockOperation()
        
        operation.addExecutionBlock { [weak self, weak operation] in
            
            if let operation = operation, operation.isCancelled {
                return
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let url = URL(string: toUrl) {
                
                let semaphore = DispatchSemaphore(value: 0)

                let manager = SocketManager(socketURL: url, config: [.log(true), .forcePolling(true)])
                let socket = manager.defaultSocket
                strongSelf.manager = manager
                strongSelf.state = .connecting
                
                socket.on(clientEvent: .connect, callback: { [weak self, weak semaphore] (_, _) in
                    self?.state = .connected
                    self?.onConnect?()
                    semaphore?.signal()
                })

                socket.on(clientEvent: .disconnect, callback: { [weak self] (_, _) in
                    self?.state = .disconnected
                    self?.onDisconnect?()
                })
                
                socket.on(clientEvent: .error, callback: { [weak self, weak semaphore] (_, _) in
                    self?.state = .connectionFailed
                    self?.onFailedConnection?()
                    semaphore?.signal()
                })
                
                socket.on(clientEvent: .reconnect, callback: { [weak self] (_, _) in
                    self?.state = .connected
                    self?.onReconnect?()
                })
                
                socket.connect(timeoutAfter: strongSelf.timeout, withHandler: { [weak semaphore] in
                    self?.state = .connectionFailed
                    self?.onFailedConnection?()
                    semaphore?.signal()
                })
                
                _ = semaphore.wait(timeout: .distantFuture)
            }
        }
        workingQueue.addOperation(operation)

    }
    
    func disconnect() {
        
        let operation: BlockOperation = BlockOperation()
        
        operation.addExecutionBlock { [weak self, weak operation] in
            
            if let operation = operation, operation.isCancelled {
                return
            }
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.socket?.disconnect()
        }
        
        workingQueue.addOperation(operation)
    }
    
    func on(event: String, callback: @escaping ([Any]) -> () ) {

        let operation: BlockOperation = BlockOperation()
        
        operation.addExecutionBlock { [weak self, weak operation] in
            
            if let operation = operation, operation.isCancelled {
                return
            }
            
            guard let socket = self?.socket else {
                return
            }
            
            socket.on(event, callback: { (data, _) in
                callback(data)
            })
        }
        
        workingQueue.addOperation(operation)
    }
    
    func emit(event: String, items: [Any]) {
        
        let operation: BlockOperation = BlockOperation()
        
        operation.addExecutionBlock { [weak self, weak operation] in
            
            if let operation = operation, operation.isCancelled {
                return
            }
            
            guard let socket = self?.socket else {
                return
            }
            
            socket.emit(event, with: items)
        }
        
        workingQueue.addOperation(operation)
    }
}
