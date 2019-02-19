//
//  ContractStructEnum.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 19/02/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Enum which contains contract struct for different VM
 */
public enum ContractStructEnum: Decodable, ContractVMTypeDecodable {
    
    case evm(ContractStructEVM)
    case x86(ContractStructx86)
    
    public init(from decoder: Decoder) throws {
        
        let vmType = try ContractStructEnum.decodeVMType(from: decoder)
        
        switch vmType {
        case ContractVMType.evm:
            let contractStruct = try ContractStructEnum.decodeObject(from: decoder, type: ContractStructEVM.self)
            self = .evm(contractStruct)
        case ContractVMType.x86:
            let contractStruct = try ContractStructEnum.decodeObject(from: decoder, type: ContractStructx86.self)
            self = .x86(contractStruct)
        }
    }
}
