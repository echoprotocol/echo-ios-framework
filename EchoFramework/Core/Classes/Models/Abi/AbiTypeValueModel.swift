//
//  AbiTypeValueModel.swift
//  QTUM
//
//  Created by Fedorenko Nikita on 02.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

public struct AbiTypeValueInputModel: Equatable {
    
    public var type: AbiParameterType
    public var value: String
    
    public init(type: AbiParameterType, value: String) {
        
        self.type = type
        self.value = value
    }
    
    public static func == (lhs: AbiTypeValueInputModel, rhs: AbiTypeValueInputModel) -> Bool {
        
        return lhs.type == rhs.type && lhs.value == rhs.value
    }

}

public  struct AbiTypeValueOutputModel: Equatable {
    
    public var type: AbiParameterType
    public var value: Any
    
    public init(type: AbiParameterType, value: Any) {
        
        self.type = type
        self.value = value
    }
    
    public static func == (lhs: AbiTypeValueOutputModel, rhs: AbiTypeValueOutputModel) -> Bool {
        
        return lhs.type == rhs.type
    }
}
