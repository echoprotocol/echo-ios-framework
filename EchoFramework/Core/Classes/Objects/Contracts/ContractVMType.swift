//
//  ContractVMType.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 19/02/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import Foundation

enum ContractVMType: Int {
    case evm
    case x86
}

protocol ContractVMTypeDecodable {
    
    static func decodeVMType(from decoder: Decoder) throws -> ContractVMType
    static func decodeObject<T>(from decoder: Decoder, type: T.Type) throws -> T where T: Decodable
}

extension ContractVMTypeDecodable {
    
    static func decodeVMType(from decoder: Decoder) throws -> ContractVMType {
        
        let container = try decoder.singleValueContainer()
        
        guard let value = try? container.decode(AnyDecodable.self),
            let array = value.value as? [Any],
            let firstNumber = array.first as? Int,
            let vmType = ContractVMType(rawValue: firstNumber) else {
                
            throw DecodingError.typeMismatch(ContractVMTypeDecodable.self,
                                             DecodingError.Context(codingPath: decoder.codingPath,
                                                                   debugDescription: "Wrong type for ContractVMTypeDecodable"))
        }
        
        return vmType
    }
    
    static func decodeObject<T>(from decoder: Decoder, type: T.Type) throws -> T where T: Decodable {
        
        let container = try decoder.singleValueContainer()
        
        guard let value = try? container.decode(AnyDecodable.self),
            let array = value.value as? [Any],
            let lastElement = array.last else {
                
            throw DecodingError.typeMismatch(ContractStructEnum.self,
                                             DecodingError.Context(codingPath: decoder.codingPath,
                                                                   debugDescription: "Wrong type for ContractStructEnum"))
        }
        
        let data = try JSONSerialization.data(withJSONObject: lastElement, options: [])
        let object = try JSONDecoder().decode(T.self, from: data)
        
        return object
    }
}
