//
//  AbiArgumentInterpretator.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 02.03.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

public protocol AbiArgumentCoder {
    
    func getArguments(valueTypes: [AbiTypeValueInputModel]) throws -> Data
    func getValueTypes(data: Data, outputs: [AbiFunctionEntries]) throws -> [AbiTypeValueOutputModel]
    func getValueTypes(string: String, outputs: [AbiFunctionEntries]) throws -> [AbiTypeValueOutputModel]
}
