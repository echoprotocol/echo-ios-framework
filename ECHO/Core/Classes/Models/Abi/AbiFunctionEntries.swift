//
//  AbiFunctionEntries.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 01.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

public class AbiFunctionEntries: Equatable, Hashable {
    
    public var name: String
    public var typeString: String
    public var type: AbiParameterType
    
    public init(name: String, typeString: String, type: AbiParameterType) {
        self.name = name
        self.typeString = typeString
        self.type = type
    }
    
    public static func == (lhs: AbiFunctionEntries, rhs: AbiFunctionEntries) -> Bool {
        return lhs.type == rhs.type
    }
    
    public var hashValue: Int {
        return type.hashValue
    }
}

public class AbiFunctionInputModel: AbiFunctionEntries { }

public class AbiFunctionOutputModel: AbiFunctionEntries { }

extension Array where Element: AbiFunctionEntries {
    
    var hashValue: Int {
        return self.reduce(5125) { masterHash, hash in masterHash ^ hash.hashValue }
    }
}
