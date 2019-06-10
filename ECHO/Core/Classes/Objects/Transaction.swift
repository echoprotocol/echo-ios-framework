//
//  Transaction.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 28.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Class used to represent a generic Graphene transaction.
 */
public final class Transaction: ECHOCodable, Decodable {
    
    private enum TransactionCodingKeys: String, CodingKey {
        case expiration
        case signatures
        case operations
        case extensions
        case refBlockNum = "ref_block_num"
        case refBlockPrefix = "ref_block_prefix"
    }
    
    static let defaultExpirationTime = 40
    
    var blockData: BlockData?
    var operations: [BaseOperation]
    var chainId: String?
    let extensions: Extensions = Extensions()
    var signatures: [Data]
    let refBlockNum: Int
    let refBlockPrefix: Int
    var expiration: Date?
    
    init(operations: [BaseOperation], blockData: BlockData, chainId: String) {
        
        self.blockData = blockData
        self.operations = operations
        self.chainId = chainId
        self.signatures = [Data]()
        refBlockNum = 0
        refBlockPrefix = 0
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
        blockData?.relativeExpiration += 1
    }
    
    // MARK: ECHOCodable
    
    public func toJSON() -> Any? {
        
        let expirationDate = Date(timeIntervalSince1970: TimeInterval(blockData?.relativeExpiration ?? 0))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Settings.defaultDateFormat
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.locale = Locale(identifier: Settings.localeIdentifier)

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
                                               TransactionCodingKeys.refBlockNum.rawValue: blockData?.refBlockNum ?? "",
                                               TransactionCodingKeys.refBlockPrefix.rawValue: blockData?.refBlockPrefix ?? "",
                                               TransactionCodingKeys.signatures.rawValue: signaturesArray]
        
        return dictionary
    }
    
    public func toData() -> Data? {
        
        var data = Data()
        data.append(optional: Data(hex: chainId ?? "0"))
        data.append(optional: blockData?.toData())
        
        data.append(optional: Data.fromArray(operations, elementToData: {
            var operationData = Data()
            operationData.append(Data.fromInt8($0.getId()))
            operationData.append(optional: $0.toData())
            return operationData
        }))
        
        data.append(optional: extensions.toData())
        
        return data
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: TransactionCodingKeys.self)
        
        let expirationString = try values.decode(String.self, forKey: .expiration)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Settings.defaultDateFormat
        dateFormatter.locale = Locale(identifier: Settings.localeIdentifier)
        
        expiration = dateFormatter.date(from: expirationString)
        refBlockNum = (try values.decode(IntOrString.self, forKey: .refBlockNum)).intValue
        refBlockPrefix = (try values.decode(IntOrString.self, forKey: .refBlockPrefix)).intValue
        signatures = (try values.decode([String].self, forKey: .signatures)).compactMap { Data(hex: $0) }
        operations = ((try values.decode(AnyDecodable.self, forKey: .operations).value as? [Any])
            .flatMap { OperationDecoder().decode(operations: $0)}) ?? [BaseOperation]()
    }
}
