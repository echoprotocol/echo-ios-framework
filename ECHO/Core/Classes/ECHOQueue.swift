//
//  ECHOQueue.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 23.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

protocol ECHOQueueble: class {
    
    var queues: [ECHOQueue] { get set }
    
    func addQueue(_ queue: ECHOQueue)
    func removeQueue(_ queue: ECHOQueue)
    
    func createLastOperation(queue: ECHOQueue) -> Operation
    func cancelAllOperationInQueues()
}

extension ECHOQueueble {
    
    func addQueue(_ queue: ECHOQueue) {
        
        queues.append(queue)
    }
    
    func removeQueue(_ queue: ECHOQueue) {
        
        if let index = queues.index(where: { return queue.uuid == $0.uuid }) {
            queues.remove(at: index)
        }
    }
    
    func createLastOperation(queue: ECHOQueue) -> Operation {
        
        let lastOperation = BlockOperation()
        
        lastOperation.addExecutionBlock { [weak self] in
            self?.removeQueue(queue)
        }
        
        return lastOperation
    }
    
    func cancelAllOperationInQueues() {
        
        for queue in queues {
            queue.cancelAllOperations()
        }
    }
}

final class ECHOQueue {

    fileprivate let workingQueue: OperationQueue
    fileprivate var valuesContainer: [String: Any?]
    fileprivate var semaphore: DispatchSemaphore
    
    let uuid: String
    
    init() {
        
        uuid = NSUUID().uuidString
        
        workingQueue = OperationQueue()
        workingQueue.maxConcurrentOperationCount = 1
        workingQueue.qualityOfService = .utility
        
        semaphore = DispatchSemaphore(value: 0)
        valuesContainer = [String: Any?]()
    }
    
    // MARK: Save and get operations results
    
    func saveValue<T>(_ value: T, forKey key: String) {

        valuesContainer[key] = value
    }
    
    func getValue<T>(_ key: String) -> T? {
        
        guard let anyValue = valuesContainer[key] else {
            return nil
        }
        
        guard let tValue = anyValue as? T else {
            return nil
        }
        
        return tValue
    }
    
    // MARK: Semaphore
    
    func waitStartNextOperation() {
        
        _ = semaphore.wait(timeout: .distantFuture)
    }
    
    func startNextOperation() {
        
        semaphore.signal()
    }
    
    // MARK: Operations
    
    func addOperation(_ operation: Operation) {
        
        workingQueue.addOperation(operation)
    }
    
    func cancelAllOperations() {
        
        workingQueue.cancelAllOperations()
    }
}
