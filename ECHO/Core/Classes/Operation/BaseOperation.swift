//
//  BaseOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 17.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

protocol BaseOperation: ECHOCodable, Decodable {
    
    var type: OperationType { get }
    var extensions: Extensions { get }
    
    func getId() -> Int
}

extension BaseOperation {
    
    func getId() -> Int {
        return type.rawValue
    }
    
    func toJSON() -> Any? {
        return [Any]()
    }
    
    func toJSON() -> String? {
        return nil
    }
    
    func toData() -> Data? {
        return nil
    }
}
