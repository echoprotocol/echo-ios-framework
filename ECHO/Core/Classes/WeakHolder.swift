//
//  WeakHolder.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 23.07.2018.
//

import Foundation

/**
 This protocol defines a box for an element.
 It's useful because we can declare both generic types (e.g. `WeakBox<T>`) and concrete types (e.g. `WeakProtocolBox`).
 */
public protocol WeakHolder {
    
    associatedtype Element
    
    /**
     A getter for the inner element. Likely, this var will be labeled as weak in your implementation.
     */
    var element: Element? { get }
    
    /**
     An initializer for the `WeakHolder`.
     This is useful to implement `map`.
     */
    init(element: Element?)
    
    /**
     A map function which returns another `WeakHolder`. This allows us to treat `WeakHolder` as a monad and create other `WeakHolders` from the current one.
     You do not need to implement this as it is implemented in the extension.
     */
    func map<T: AnyObject, U: WeakHolder>(_ transform: (Element) throws -> T) rethrows -> U where U.Element == T
}

extension WeakHolder {
    public func map<T: AnyObject, U: WeakHolder>(_ transform: (Element) throws -> T) rethrows -> U where U.Element == T {
        // First, we want to create a new element from the current element using the transform function provided
        let newElement = try element.flatMap(transform)
        // Then, we simply initialzed U with the new element.
        return U.init(element: newElement)
    }
}

/**
 This defines a WeakHolder which specifically holds a ConsistencyManagerListener.
 This is useful because WeakBox<ConsistencyManagerListener> is illegal in Swift. You need a concrete type like this one.
 */

public struct WeakListenerBox: WeakHolder {
    
    public typealias Element = SubscribeAccountDelegate
    
    
    // Sadly, we need to declare this because by default, it's internal
    public init(element: SubscribeAccountDelegate?) {
        self.element = element
    }
    
    public weak var element: SubscribeAccountDelegate?
}
