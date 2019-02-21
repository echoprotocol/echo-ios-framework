//
//  ContractResultEVM.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 10.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Model of contract operation result for VM type Etherium
 */
public struct ContractResultEVM: Decodable {
    
    private enum ContractResultEVMCodingKeys: String, CodingKey {
        case execRes = "exec_res"
        case trReceipt = "tr_receipt"
    }
    
    public let execRes: ExecRes
    public let trReceipt: TrReceipt
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: ContractResultEVMCodingKeys.self)
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
    
    public let excepted: String?
    public let newAddress: String?
    public let output: String?
    public let codeDeposit: String?
    public let gasRefunded: UInt?
    public let depositSize: UInt?
    public let gasForDeposit: UInt?
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: ExecResCodingKeys.self)
        excepted = try? values.decode(String.self, forKey: .excepted)
        newAddress = try? values.decode(String.self, forKey: .newAddress)
        output = try? values.decode(String.self, forKey: .output)
        codeDeposit = try? values.decode(String.self, forKey: .codeDeposit)
        gasRefunded = try? values.decode(UInt.self, forKey: .gasRefunded)
        depositSize = try? values.decode(UInt.self, forKey: .depositSize)
        gasForDeposit = try? values.decode(UInt.self, forKey: .gasForDeposit)
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
    
    public let statusCode: UInt?
    public let gasUsed: UInt?
    public let bloom: String?
    public let log: [Log]?
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: TrReceiptCodingKeys.self)
        statusCode = try? values.decode(UInt.self, forKey: .statusCode)
        gasUsed = try? values.decode(UInt.self, forKey: .gasUsed)
        bloom = try? values.decode(String.self, forKey: .bloom)
        log = try? values.decode([Log].self, forKey: .log)
    }
}

/**
    Information about log
 */
public struct Log: Decodable {
    
    private enum LogCodingKeys: String, CodingKey {
        case address
        case log
        case data
    }
    
    public let data: String
    public let address: String
    public let log: [String]
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: LogCodingKeys.self)
        data = try values.decode(String.self, forKey: .data)
        address = try values.decode(String.self, forKey: .address)
        log = try values.decode([String].self, forKey: .log)
    }
}
