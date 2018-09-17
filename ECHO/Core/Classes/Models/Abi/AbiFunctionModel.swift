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
    
    public var hashValue: Int {
        return name.hashValue ^ (isConstant ? 1:0) ^ (isPyable ? 1:0) ^ type.hashValue ^ inputs.hashValue ^ outputs.hashValue
    }
}
