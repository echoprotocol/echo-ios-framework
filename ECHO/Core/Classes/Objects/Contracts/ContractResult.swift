//
//  ContractResult.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 10.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Model of contract operation result
 */
public struct ContractResult: Decodable {
    
    private enum ContractResultCodingKeys: String, CodingKey {
        case execRes = "exec_res"
        case trReceipt = "tr_receipt"
    }
    
    let execRes: ExecRes
    let trReceipt: TrReceipt
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: ContractResultCodingKeys.self)
        execRes = try values.decode(ExecRes.self, forKey: .execRes)
        trReceipt = try values.decode(TrReceipt.self, forKey: .trReceipt)
    }
}

/**
    Information about operation executing
 */
public struct ExecRes: Decodable {

    private enum ExecResCodingKeys: String, CodingKey {
        case excepted
        case newAddress = "new_address"
        case output
        case codeDeposit = "code_deposit"
        case gasRefunded = "gas_refunded"
        case depositSize = "deposit_size"
        case gasForDeposit = "gas_for_deposit"
    }
    
    let excepted: String?
    let newAddress: String?
    let output: String?
    let codeDeposit: String?
    let gasRefunded: String?
    let depositSize: Int?
    let gasForDeposit: String?
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: ExecResCodingKeys.self)
        excepted = try? values.decode(String.self, forKey: .excepted)
        newAddress = try? values.decode(String.self, forKey: .newAddress)
        output = try? values.decode(String.self, forKey: .output)
        codeDeposit = try? values.decode(String.self, forKey: .codeDeposit)
        gasRefunded = try? values.decode(String.self, forKey: .gasRefunded)
        depositSize = try? values.decode(Int.self, forKey: .depositSize)
        gasForDeposit = try? values.decode(String.self, forKey: .gasForDeposit)
    }
}

/**
    Information about transaction
 */
public struct TrReceipt: Decodable {

    private enum TrReceiptCodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case gasUsed = "gas_used"
        case bloom
        case log
    }
    
    let statusCode: String?
    let gasUsed: String?
    let bloom: String?
    let log: [String]?
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: TrReceiptCodingKeys.self)
        statusCode = try? values.decode(String.self, forKey: .statusCode)
        gasUsed = try? values.decode(String.self, forKey: .gasUsed)
        bloom = try? values.decode(String.self, forKey: .bloom)
        log = try? values.decode([String].self, forKey: .log)
    }
}
