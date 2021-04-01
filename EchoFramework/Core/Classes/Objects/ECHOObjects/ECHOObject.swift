//
//  ECHOObject.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

protocol ECHOObject: ECHOCodable {
    var id: String { get }
}

extension ECHOObject {
    
    public func toData() -> Data? {
        
        guard let instance = getInstance() else {
            return nil
        }
        
        return Data.fromUIntLikeUnsignedByteArray(instance)
    }
    
    public func toJSON() -> Any? {
        return id
    }
    
    func getSpace() -> UInt? {
        
        return getIdSubUIntAt(index: 0)
    }
    
    func getType() -> UInt? {
        
        return getIdSubUIntAt(index: 1)
    }
    
    func getInstance() -> UInt? {
        
        return getIdSubUIntAt(index: 2)
    }
    
    fileprivate func getIdSubUIntAt(index: Int) -> UInt? {
        
        let values = id.components(separatedBy: ".")
        guard let string = values[safe: index] else {
            return nil
        }
        return UInt(string)
    }
}
