//
//  ECHOQueue.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 23.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Protocol for object which want work with [ECHOQueue](ECHOQueue)
 
    - Save reference to queue
    - Operation for delete queue after complete
    - Cancel all operations in all queues
 */
protocol ECHOQueueble: class {
    
    var queues: [ECHOQueue] { get set }
    
    func addQueue(_ queue: ECHOQueue)
    func removeQueue(_ queue: ECHOQueue)
    
    func createCompletionOperation(queue: ECHOQueue) -> Operation
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
    
    func createCompletionOperation(queue: ECHOQueue) -> Operation {
        
        let completionOperation = BlockOperation()
        
        completionOperation.addExecutionBlock { [weak self] in
            self?.removeQueue(queue)
        }
        
        return completionOperation
    }
    
    func cancelAllOperationInQueues() {
        
        for queue in queues {
            queue.cancelAllOperations()
        }
    }
}

/**
    Custom Queue which contains [OperationQueue](OperationQueue) and [DispatchSemaphore](DispatchSemaphore)
 
    - Stop queue while async operation working
    - Storage for values between operations
 */
final class ECHOQueue: NSObject {

    fileprivate let workingQueue: OperationQueue
    fileprivate var valuesContainer: [String: Any?]
    fileprivate var semaphore: DispatchSemaphore
    fileprivate var completionOperation: Operation?
    fileprivate var obs: NSKeyValueObservation?
    
    let uuid: String
    
    override init() {
        
        uuid = NSUUID().uuidString
        
        workingQueue = OperationQueue()
        workingQueue.maxConcurrentOperationCount = 1
        workingQueue.qualityOfService = .utility
        
        semaphore = DispatchSemaphore(value: 0)
        valuesContainer = [String: Any?]()
    }
    
    deinit {
        workingQueue.removeObserver(self, forKeyPath: "operationCount")
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
    
    func setCompletionOperation(_ completionOperation: Operation) {
        
        self.completionOperation = completionOperation
        
        obs = workingQueue.observe(\.operationCount) { [weak self](queue, _) in
            
            if queue.operationCount == 0,
                let completionOperation = self?.completionOperation,
                completionOperation.isFinished == false {
                queue.addOperation(completionOperation)
            }
        }
    }
    
    func addOperation(_ operation: Operation) {
        workingQueue.addOperation(operation)
    }
    
    func cancelAllOperations() {
        
        workingQueue.cancelAllOperations()
    }
}
