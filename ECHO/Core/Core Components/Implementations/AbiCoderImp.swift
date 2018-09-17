//
//  AbiCoderImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 03.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

final class AbiCoderImp: AbiCoder {
    
    let argumentCoder: AbiArgumentCoder
    
    init(argumentCoder: AbiArgumentCoder) {
        self.argumentCoder = argumentCoder
    }
    
    func getArguments(valueTypes: [AbiTypeValueInputModel]) throws -> Data {
        return try argumentCoder.getArguments(valueTypes: valueTypes)
    }
    
    func getValueTypes(data: Data, abiFunc: AbiFunctionModel) throws -> [AbiTypeValueOutputModel] {
        return try argumentCoder.getValueTypes(data: data, abiFunc: abiFunc)

    }
    func getValueTypes(string: String, abiFunc: AbiFunctionModel) throws -> [AbiTypeValueOutputModel] {
        return try argumentCoder.getValueTypes(string: string, abiFunc: abiFunc)
    }
    
    func getHash(abiFunc: AbiFunctionModel) throws -> Data {
        
        let string = try getStringHash(abiFunc: abiFunc)
        
        if let data = Data(hex: string) {
            return data
        } else {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            throw error
        }
    }
    
    func getHash(abiFunc: AbiFunctionModel, param: [AbiTypeValueInputModel]) throws -> Data {
        
        let paramHash = try argumentCoder.getArguments(valueTypes: param)
        var functionHash = try getHash(abiFunc: abiFunc)
        functionHash.append(paramHash)
        
        return functionHash
    }
    
    fileprivate func bridge(_ param: String, _ funcName: String) -> String {
        let fullFunc = "\(funcName)(\(param))"
        return fullFunc.sha3(.keccak256)[0..<8]
    }
    
    func getStringHash(abiFunc: AbiFunctionModel) throws -> String {
        
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
    
    func getStringHash(abiFunc: AbiFunctionModel, param: [AbiTypeValueInputModel]) throws -> String {
        
        let dataHash = try getHash(abiFunc: abiFunc, param: param)
        return dataHash.hex
    }
    
    func getStringHash(funcName: String) throws -> String {
        return (funcName + "()").sha3(.keccak256)[0..<8]
    }
    
    func getStringHash(funcName: String, param: [AbiTypeValueInputModel]) throws -> String {
        
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
    
    func getBytecode(bytecode: Data, constructor: AbiFunctionModel, param: [AbiTypeValueInputModel]) throws -> Data {
        
        let paramHash = try getArguments(valueTypes: param)
        var bytecodeCreator = bytecode
        bytecodeCreator.append(paramHash)
        return bytecodeCreator
    }
    
    func getStringBytecode(bytecode: Data, constructor: AbiFunctionModel, param: [AbiTypeValueInputModel]) throws -> String {
        return try getBytecode(bytecode: bytecode, constructor: constructor, param: param).hex
    }
}
