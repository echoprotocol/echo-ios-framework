//
//  WeakBox.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 23.07.2018.
//

import Foundation

/**
 This is a generic implementation of `WeakHolder` which we use the in `WeakArray` class.
 */
public struct WeakBox<T: AnyObject>: WeakHolder {
    
    // Sadly, we need to declare this because by default, it's internal
    public init(element: T?) {
        self.element = element
    }
    
    public weak var element: T?
}
