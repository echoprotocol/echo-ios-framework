//
//  ContractLogEnum.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 14.10.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Enum which contains contract log for different VM
 */
public enum ContractLogEnum: Decodable, ContractVMTypeDecodable {
    
    case evm(ContractLogEVM)
    case x86(ContractLogx86)
    
    public init(from decoder: Decoder) throws {
        
        let vmType = try ContractLogEnum.decodeVMType(from: decoder)
        
        switch vmType {
        case ContractVMType.evm:
            let contractLog = try ContractLogEnum.decodeObject(from: decoder, type: ContractLogEVM.self)
            self = .evm(contractLog)
        case ContractVMType.x86:
            let contractLog = try ContractLogEnum.decodeObject(from: decoder, type: ContractLogx86.self)
            self = .x86(contractLog)
        }
    }
}
