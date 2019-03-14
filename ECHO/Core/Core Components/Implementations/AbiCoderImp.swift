//
//  AbiCoderImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 03.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

public final class AbiCoderImp: AbiCoder {
    
    let argumentCoder: AbiArgumentCoder
    
    public init(argumentCoder: AbiArgumentCoder) {
        self.argumentCoder = argumentCoder
    }
    
    public func getArguments(valueTypes: [AbiTypeValueInputModel]) throws -> Data {
        return try argumentCoder.getArguments(valueTypes: valueTypes)
    }
    
    public func getValueTypes(data: Data, outputs: [AbiFunctionEntries]) throws -> [AbiTypeValueOutputModel] {
        return try argumentCoder.getValueTypes(data: data, outputs: outputs)

    }
    
    public func getValueTypes(string: String, outputs: [AbiFunctionEntries]) throws -> [AbiTypeValueOutputModel] {
        return try argumentCoder.getValueTypes(string: string, outputs: outputs)
    }
    
    public func getHash(abiFunc: AbiFunctionModel) throws -> Data {
        
        let string = try getStringHash(abiFunc: abiFunc)
        
        if let data = Data(hex: string) {
            return data
        } else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
    }
    
    public func getHash(abiFunc: AbiFunctionModel, param: [AbiTypeValueInputModel]) throws -> Data {
        
        let paramHash = try argumentCoder.getArguments(valueTypes: param)
        var functionHash = try getHash(abiFunc: abiFunc)
        functionHash.append(paramHash)
        
        return functionHash
    }
    
    fileprivate func bridge(_ param: String, _ funcName: String) -> String {
        let fullFunc = "\(funcName)(\(param))"
        return fullFunc.sha3(.keccak256)[0..<8]
    }
    
    public func getStringHash(abiFunc: AbiFunctionModel) throws -> String {
        
        var param = ""
        
        for index in 0..<abiFunc.inputs.count {
            
            if index != abiFunc.inputs.count - 1 {
                param +=  abiFunc.inputs[index].typeString + ","
            } else {
                param += abiFunc.inputs[index].typeString
            }
        }
        
        return bridge(param, abiFunc.name)
    }
    
    public func getStringHash(abiFunc: AbiFunctionModel, param: [AbiTypeValueInputModel]) throws -> String {
        
        let dataHash = try getHash(abiFunc: abiFunc, param: param)
        return dataHash.hex
    }
    
    public func getStringHash(funcName: String) throws -> String {
        return (funcName + "()").sha3(.keccak256)[0..<8]
    }
    
    public func getStringHash(funcName: String, param: [AbiTypeValueInputModel]) throws -> String {
        
        let paramHashString = try argumentCoder.getArguments(valueTypes: param).hex
        var paramString = ""
        
        for index in 0..<param.count {
            
            if index != param.count - 1 {
                paramString +=  param[index].type.description + ","
            } else {
                paramString += param[index].type.description
            }
        }
        
        return bridge(paramString, funcName) + paramHashString
    }
    
    public func getBytecode(bytecode: Data, constructor: AbiFunctionModel, param: [AbiTypeValueInputModel]) throws -> Data {
        
        let paramHash = try getArguments(valueTypes: param)
        var bytecodeCreator = bytecode
        bytecodeCreator.append(paramHash)
        return bytecodeCreator
    }
    
    public func getStringBytecode(bytecode: Data, constructor: AbiFunctionModel, param: [AbiTypeValueInputModel]) throws -> String {
        return try getBytecode(bytecode: bytecode, constructor: constructor, param: param).hex
    }
}
