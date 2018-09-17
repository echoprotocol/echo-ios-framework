//
//  AbiFunctionEntries.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 01.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

class AbiFunctionEntries: Equatable, Hashable {    
    
    var name: String
    var typeString: String
    var type: AbiParameterType
    
    init(name: String, typeString: String, type: AbiParameterType) {
        self.name = name
        self.typeString = typeString
        self.type = type
    }
    
    static func == (lhs: AbiFunctionEntries, rhs: AbiFunctionEntries) -> Bool {
        return lhs.type == rhs.type
    }
    
    var hashValue: Int {
        return type.hashValue
    }
}

class AbiFunctionInputModel: AbiFunctionEntries { }

class AbiFunctionOutputModel: AbiFunctionEntries { }

extension Array where Element: AbiFunctionEntries {
    
    var hashValue: Int {
        return self.reduce(5125) { masterHash, hash in masterHash ^ hash.hashValue }
    }
}
