//
//  ContractExecuteType.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 13/03/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
 Enum present execute type fo contract operation. Can use only code or create code by method name and params
 */
enum ContractExecuteType {
    case code(String)
    case nameAndParams(String, [AbiTypeValueInputModel])
}
