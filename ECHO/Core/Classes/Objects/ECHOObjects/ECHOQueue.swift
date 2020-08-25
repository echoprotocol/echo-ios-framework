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
public protocol ECHOQueueble: class {
    
    var queues: [String: ECHOQueue] { get set }
    
    func addQueue(_ queue: ECHOQueue)
    func removeQueue(_ queue: ECHOQueue)
    
    func createCompletionOperation(queue: ECHOQueue) -> Operation
    func startNextOperationIfNeedFor(_ queue: ECHOQueue)
    func cancelAllOperationInQueues()
}

public extension ECHOQueueble {
    
    func addQueue(_ queue: ECHOQueue) {
        
        queues[queue.uuid] = queue
    }
    
    func removeQueue(_ queue: ECHOQueue) {
        
        queues.removeValue(forKey: queue.uuid)
    }
    
    func createCompletionOperation(queue: ECHOQueue) -> Operation {
        
        let completionOperation = BlockOperation()
        
        completionOperation.addExecutionBlock { [weak self, weak queue] in
            if let queue = queue {
                self?.removeQueue(queue)
            }
        }
        
        return completionOperation
    }
    
    func cancelAllOperationInQueues() {
        
        for queue in queues.values {
            queue.cancelAllOperations()
        }
    }
    
    func startNextOperationIfNeedFor(_ queue: ECHOQueue) {
        
        let waitingOperations = queue.getOperations().compactMap {
            return $0 as? WaitQueueOperation
        }
        
        waitingOperations.forEach {
            if $0.isWaiting {
                $0.stopWaiting()
            }
        }
    }
}

/**
    Custom Queue which contains [OperationQueue](OperationQueue) and [DispatchSemaphore](DispatchSemaphore)
 
    - Stop queue while async operation working
    - Storage for values between operations
 */
public final class ECHOQueue: NSObject {

    fileprivate let workingQueue: OperationQueue
    fileprivate var valuesContainer: [String: Any?]
    fileprivate var semaphore: DispatchSemaphore
    fileprivate var completionOperation: Operation?
    fileprivate var obs: NSKeyValueObservation?
    
    public let uuid: String
    
    public override init() {
        
        uuid = NSUUID().uuidString
        
        workingQueue = OperationQueue()
        workingQueue.maxConcurrentOperationCount = 1
        workingQueue.qualityOfService = .utility
        
        semaphore = DispatchSemaphore(value: 0)
        valuesContainer = [String: Any]()
    }
    
    // MARK: Save and get operations results
    
    public func saveValue<T>(_ value: T, forKey key: String) {

        valuesContainer[key] = value
    }
    
    public func getValue<T>(_ key: String) -> T? {
        
        guard let anyValue = valuesContainer[key] else {
            return nil
        }
        
        guard let tValue = anyValue as? T else {
            return nil
        }
        
        return tValue
    }
    
    // MARK: Semaphore
    
    public func waitStartNextOperation() {
        
        _ = semaphore.wait(timeout: .distantFuture)
    }
    
    public func startNextOperation() {
        
        semaphore.signal()
    }
    
    // MARK: Operations
    
    public func addOperation(_ operation: Operation) {
        workingQueue.addOperation(operation)
    }
    
    public func cancelAllOperations() {
        workingQueue.cancelAllOperations()
    }
    
    public func getOperations() -> [Operation] {
        return workingQueue.operations
    }
}

/**
   Main keys for repeated values in EchoQueue
*/
public enum EchoQueueMainKeys: String {
    case operationId
    case notice
    case noticeError
    case noticeHandler
}
