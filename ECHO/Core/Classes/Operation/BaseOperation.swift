//
//  BaseOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 17.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Represents base operation model in ECHO blockchain
 */
public protocol BaseOperation: ECHOCodable, Decodable {
    
    var type: OperationType { get }
    var extensions: Extensions { get }
    var fee: AssetAmount { get set }
    
    func getId() -> Int
}

extension BaseOperation {
    
    public func getId() -> Int {
        return type.rawValue
    }
}
