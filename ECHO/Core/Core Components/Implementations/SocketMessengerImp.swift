//
//  SocketCoreComponentImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 26.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation
import Starscream

/**
 Implementation of [SocketMessenger](SocketMessenger)
 */
final class SocketMessengerImp: SocketMessenger {
    
    var callbackQueue: DispatchQueue = DispatchQueue.main
    var state: SocketConnectionState = .notConnected
    var onConnect: (() -> ())?
    var onReconnect: (() -> ())?
    var onDisconnect: (() -> ())?
    var onFailedConnect: (() -> ())?
    var onText: ((String) -> ())?

    var timeout: Double = 3
    
    var socket: WebSocket?
    
    var workingQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    var semaphore: DispatchSemaphore = {
        return DispatchSemaphore(value: 0)
    }()
    
    func connect(toUrl: String) {
        
        clearPreviousState()
        
        let operation: BlockOperation = BlockOperation()
        
        operation.addExecutionBlock { [weak self, weak operation] in
            
            if let operation = operation, operation.isCancelled {
                return
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let url = URL(string: toUrl) {
                
                let socket = WebSocket(url: url)
                strongSelf.socket = socket
                strongSelf.state = .connecting
                socket.callbackQueue = strongSelf.callbackQueue
                
                socket.onConnect = { [weak self] in
                    self?.state = .connected
                    self?.onConnect?()
                    self?.semaphore.signal()
                }
                
                socket.onDisconnect = { [weak self] (error: Error?) in
                    self?.state = .disconnected
                    self?.onDisconnect?()
                }
                
                socket.onText = strongSelf.onText
                socket.connect()
                
                _ = strongSelf.semaphore.wait(timeout: .distantFuture)
            } else {
                strongSelf.onFailedConnect?()
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
    
    func write(_ string: String) {
        
        print(string)
        
        let operation: BlockOperation = BlockOperation()
        
        operation.addExecutionBlock { [weak self, weak operation] in
            
            if let operation = operation, operation.isCancelled {
                return
            }
            
            guard let socket = self?.socket else {
                return
            }
            
            socket.write(string: string)
        }
        
        workingQueue.addOperation(operation)
    }
    
    func clearPreviousState() {
        
        workingQueue.cancelAllOperations()
        semaphore.signal()
    }
}
