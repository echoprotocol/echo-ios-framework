//
//  AbiTypeValueModel.swift
//  QTUM
//
//  Created by Fedorenko Nikita on 02.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

public struct AbiTypeValueInputModel: Equatable {
    
    var type: AbiParameterType
    var value: String
    
    public static func == (lhs: AbiTypeValueInputModel, rhs: AbiTypeValueInputModel) -> Bool {
        
        return lhs.type == rhs.type && lhs.value == rhs.value
    }

}

public  struct AbiTypeValueOutputModel: Equatable {
    
    var type: AbiParameterType
    var value: Any
    
    public static func == (lhs: AbiTypeValueOutputModel, rhs: AbiTypeValueOutputModel) -> Bool {
        
        return lhs.type == rhs.type
    }
}
