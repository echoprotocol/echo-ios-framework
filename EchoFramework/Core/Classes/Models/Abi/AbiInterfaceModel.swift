//
//  AbiInterfaceModel.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 01.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

struct AbiInterfaceModel {
    
    var functions: [AbiFunctionModel]
    var properties: [AbiFunctionModel]
    var constructor: AbiFunctionModel
    
    func contains(interface: AbiInterfaceModel) -> Bool {
        
        guard contains(funcs: interface.functions) else {
            return false
        }
        
        guard contains(properts: interface.properties) else {
            return false
        }
        
        return contains(aConstructor: interface.constructor)
    }
    
    func contains(funcs: [AbiFunctionModel]) -> Bool {
        
        var contains = true
        let hashes = Set(functions)
        
        for index in 0..<funcs.count {
            
            let theirFunc = funcs[index]
            
            if hashes.contains(theirFunc) == false {
                contains = false
                break
            }
        }

        return contains
    }
    
    func contains(properts: [AbiFunctionModel]) -> Bool {
        
        var contains = true
        let hashes = Set(properties)
        
        for index in 0..<properts.count {
            
            let theirProperty = properts[index]
            
            if hashes.contains(theirProperty) == false {
                contains = false
                break
            }
        }
        
        return contains
    }
    
    func contains(aConstructor: AbiFunctionModel) -> Bool {
        
        guard constructor.name == aConstructor.name else {
            return false
        }
        
        guard constructor.isConstant == aConstructor.isConstant else {
            return false
        }
        
        guard constructor.isPyable == aConstructor.isPyable else {
            return false
        }
        
        guard constructor.type == aConstructor.type else {
            return false
        }
        
        var contains = true
        let hashesImputs = Set(constructor.inputs)
        
        for index in 0..<aConstructor.inputs.count {
            
            let theirImput = aConstructor.inputs[index]
            
            if hashesImputs.contains(theirImput) == false {
                contains = false
                break
            }
        }
        
        let hashesOutputs = Set(constructor.outputs)
        
        for index in 0..<aConstructor.outputs.count {
            
            let theirOutput = aConstructor.outputs[index]
            
            if hashesOutputs.contains(theirOutput) == false {
                contains = false
                break
            }
        }
        
        return contains
    }
}
