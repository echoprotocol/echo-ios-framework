//
//  Transaction.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 28.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

class Transaction: ECHOCodable {
    
    enum TransactionCodingKeys: String, CodingKey {
        case expiration
        case signatures
        case operations
        case extensions
        case refBlockNum = "ref_block_num"
        case refBlockPrefix = "ref_block_prefix"
    }
    
    static let defaultExpirationTime = 40
    
    var blockData: BlockData
    var operations: [BaseOperation]
    let chainId: String
    let extensions: Extensions
    var signatures: [Data]
    
    init(operations: [BaseOperation], blockData: BlockData, chainId: String) {
        
        self.blockData = blockData
        self.operations = operations
        self.chainId = chainId
        self.extensions = Extensions()
        self.signatures = [Data]()
    }
    
    func setFees(_ fees: [AssetAmount]) {
        
        for operationIndex in 0..<operations.count {
            
            guard let fee = fees[safe: operationIndex] else { continue }
            var operation = operations[operationIndex]
            
            operation.fee = fee
            operations[operationIndex] = operation
        }
    }
    
    func increaseExpiration() {
        blockData.relativeExpiration += 1
    }
    
    // MARK: ECHOCodable
    
    func toJSON() -> Any? {
        
        let expirationDate = Date(timeIntervalSince1970: TimeInterval(blockData.relativeExpiration))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Settings.defaultDateFormat
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateSring = dateFormatter.string(from: expirationDate)
        
        var operationsArray = [Any?]()
        operations.forEach {
            operationsArray.append($0.toJSON())
        }
        
        var signaturesArray = [Any]()
        signatures.forEach {
            signaturesArray.append($0.hex)
        }
        
        let dictionary: [AnyHashable: Any?] = [TransactionCodingKeys.expiration.rawValue: dateSring,
                                               TransactionCodingKeys.operations.rawValue: operationsArray,
                                               TransactionCodingKeys.extensions.rawValue: extensions.toJSON(),
                                               TransactionCodingKeys.refBlockNum.rawValue: blockData.refBlockNum,
                                               TransactionCodingKeys.refBlockPrefix.rawValue: blockData.refBlockPrefix,
                                               TransactionCodingKeys.signatures.rawValue: signaturesArray]
        
        return dictionary
    }
    
    func toData() -> Data? {
        
        var data = Data()
        data.append(optional: Data(hex: chainId))
        data.append(optional: blockData.toData())
        
        data.append(optional: Data.fromArray(operations, elementToData: {
            var operationData = Data()
            operationData.append(Data.fromInt8($0.getId()))
            operationData.append(optional: $0.toData())
            return operationData
        }))
        
        data.append(optional: extensions.toData())
        
        return data
    }
}
