//
//  OptionalValue.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 20.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct OptionalValue<T>: ECHOCodable where T: ECHOCodable {
    
    let object: T?
    
    init(_ object: T?) {
        self.object = object
    }
    
    func isSet() -> Bool {
        return object != nil
    }
    
    // MARK: ECHOCodable
    
    func toJSON() -> Any? {
        return object?.toJSON()
    }
    
    func toJSON() -> String? {
        return object?.toJSON()
    }
    
    func toData() -> Data? {
        
        guard let object = object else {
            return Data(count: 1)
        }
        
        return object.toData()
    }
}
