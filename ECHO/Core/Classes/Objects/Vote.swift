//
//  Vote.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 20.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Represents vote model in graphene blockchain
 */
struct Vote: ECHOCodable {
    
    var type: Int = 0
    var instance: Int = 0
    
    init(_ voteString: String) {
        
        let params = voteString.components(separatedBy: ":")
        if let typeString = params[safe: 0], let typeInt = Int(typeString) {
            self.type = typeInt
        }
        if let instanceString = params[safe: 1], let instanceInt = Int(instanceString) {
            self.instance = instanceInt
        }
    }
    
    init(type: Int, instance: Int) {
        
        self.type = type
        self.instance = instance
    }
    
    // MARK: ECHOCodable
    
    func toJSON() -> Any? {
        return nil
    }
    
    func toJSON() -> String? {
        return "\(type)" + ":" + "\(instance)"
    }
    
    func toData() -> Data? {
        var data = Data()
        //TODO: check
        data.append(optional: Data.fromInt16(type))
        data.append(optional: Data.fromInt16(instance))
        return data
    }
}
