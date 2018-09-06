//
//  PointerArray.swift
//  QTUM
//
//  Created by Fedorenko Nikita on 20.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

extension NSPointerArray {
    
    func addObject(_ object: AnyObject?) {
        guard let strongObject = object else { return }
        
        let pointer = Unmanaged.passUnretained(strongObject).toOpaque()
        addPointer(pointer)
    }
    
    func object(at index: Int) -> AnyObject? {
        guard index < count, let pointer = self.pointer(at: index) else { return nil }
        return Unmanaged<AnyObject>.fromOpaque(pointer).takeUnretainedValue()
    }
    
    func removeObject(at index: Int) {
        guard index < count && index > 0 else { return }
        
        removePointer(at: index)
    }
}
