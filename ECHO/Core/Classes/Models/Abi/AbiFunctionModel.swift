//
//  AbiFunctionModel.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 01.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

public enum AbiFunctionType: String {
    
    case function
    case constructor
    case fallback
    case undefined 
}

public struct AbiFunctionModel: Equatable, Hashable {
    
    var name: String
    var isConstant: Bool
    var isPyable: Bool
    var type: AbiFunctionType
    var inputs: [AbiFunctionEntries]
    var outputs: [AbiFunctionEntries]
    
    public init(name: String,
                isConstant: Bool,
                isPyable: Bool,
                type: AbiFunctionType,
                inputs: [AbiFunctionEntries],
                outputs: [AbiFunctionEntries]) {
        
        self.name = name
        self.isConstant = isConstant
        self.isPyable = isPyable
        self.type = type
        self.inputs = inputs
        self.outputs = outputs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(isConstant)
        hasher.combine(isPyable)
        hasher.combine(type)
        hasher.combine(inputs)
        hasher.combine(outputs)
    }
}
