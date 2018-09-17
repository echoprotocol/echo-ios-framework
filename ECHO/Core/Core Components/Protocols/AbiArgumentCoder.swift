//
//  AbiArgumentInterpretator.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 02.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

protocol AbiArgumentCoder {
    
    func getArguments(valueTypes: [AbiTypeValueInputModel]) throws -> Data
    func getValueTypes(data: Data, abiFunc: AbiFunctionModel) throws -> [AbiTypeValueOutputModel]
    func getValueTypes(string: String, abiFunc: AbiFunctionModel) throws -> [AbiTypeValueOutputModel]
}
