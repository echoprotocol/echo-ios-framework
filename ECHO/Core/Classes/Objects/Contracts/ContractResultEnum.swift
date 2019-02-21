//
//  ContractResultEnum.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 19/02/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Enum which contains contract result for different VM
 */
public enum ContractResultEnum: Decodable, ContractVMTypeDecodable {
    
    case evm(ContractResultEVM)
    case x86(ContractResultx86)
    
    public init(from decoder: Decoder) throws {
        
        let vmType = try ContractResultEnum.decodeVMType(from: decoder)
        
        switch vmType {
        case ContractVMType.evm:
            let contractStruct = try ContractResultEnum.decodeObject(from: decoder, type: ContractResultEVM.self)
            self = .evm(contractStruct)
        case ContractVMType.x86:
            let contractStruct = try ContractResultEnum.decodeObject(from: decoder, type: ContractResultx86.self)
            self = .x86(contractStruct)
        }
    }
}
