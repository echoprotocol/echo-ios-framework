//
//  AbiTypeValueModel.swift
//  QTUM
//
//  Created by Fedorenko Nikita on 02.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

struct AbiTypeValueInputModel: Equatable {
    
    var type: AbiParameterType
    var value: String
    
    static func == (lhs: AbiTypeValueInputModel, rhs: AbiTypeValueInputModel) -> Bool {
        
        return lhs.type == rhs.type && lhs.value == rhs.value
    }

}

struct AbiTypeValueOutputModel: Equatable {
    
    var type: AbiParameterType
    var value: Any
    
    static func == (lhs: AbiTypeValueOutputModel, rhs: AbiTypeValueOutputModel) -> Bool {
        
        return lhs.type == rhs.type
    }
}
