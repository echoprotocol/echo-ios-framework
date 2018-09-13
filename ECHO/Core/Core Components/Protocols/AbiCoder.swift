//
//  AbiCoder.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 03.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

public protocol AbiCoder {
    
    func getArguments(valueTypes: [AbiTypeValueInputModel]) throws -> Data
    func getValueTypes(data: Data, abiFunc: AbiFunctionModel) throws -> [AbiTypeValueOutputModel]
    func getValueTypes(string: String, abiFunc: AbiFunctionModel) throws -> [AbiTypeValueOutputModel]
    
    func getHash(abiFunc: AbiFunctionModel) throws -> Data
    func getHash(abiFunc: AbiFunctionModel, param: [AbiTypeValueInputModel]) throws -> Data
    
    func getStringHash(abiFunc: AbiFunctionModel) throws -> String
    func getStringHash(abiFunc: AbiFunctionModel, param: [AbiTypeValueInputModel]) throws -> String
    
    func getStringHash(funcName: String) throws -> String
    func getStringHash(funcName: String, param: [AbiTypeValueInputModel]) throws -> String
    
    func getBytecode(bytecode: Data, constructor: AbiFunctionModel, param: [AbiTypeValueInputModel]) throws -> Data
    func getStringBytecode(bytecode: Data, constructor: AbiFunctionModel, param: [AbiTypeValueInputModel]) throws -> String
}
