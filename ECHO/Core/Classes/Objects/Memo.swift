//
//  Memo.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 22.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Represents additional transfer operation payload
 
    [Memo model documentations](https://dev-doc.myecho.app/structgraphene_1_1chain_1_1memo__data.html)
 */
public struct Memo: ECHOCodable, Decodable {
    
    enum MemoCodingKeys: String, CodingKey {
        case fromAccount = "from"
        case toAccount = "to"
        case nonce
        case message
    }
    
    public let nonceRadix: Int = 10
    public let paddedNonceArraySize: Int = 8
    
    public var source: Address?
    public var destination: Address?
    public let nonce: UInt
    public var byteMessage: Data?
    public var plaintextMessage: String?
    
    init() {
        nonce = 0
    }
    
    init(source: Address?, destination: Address?, nonce: UInt, byteMessage: Data?) {
        
        self.source = source
        self.destination = destination
        self.nonce = nonce
        self.byteMessage = byteMessage
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: MemoCodingKeys.self)
        
        let fromAddress = try? values.decode(String.self, forKey: .fromAccount)
        let toAddress = try? values.decode(String.self, forKey: .toAccount)
        if let fromAddress = fromAddress { source = Address(fromAddress, data: nil) }
        if let toAddress = toAddress { destination = Address(toAddress, data: nil) }
        
        if let nonceString = try? values.decode(String.self, forKey: .nonce) {
            nonce = UInt(nonceString) ?? 0
        } else if let nonceValue = try? values.decode(UInt.self, forKey: .nonce) {
            nonce = nonceValue
        } else {
            nonce = 0
        }
        
        if let byteMessageString = try? values.decode(String.self, forKey: .message) {
            byteMessage = Data(hex: byteMessageString)
        } else {
            byteMessage = try values.decode(Data.self, forKey: .message)
        }
    }
    
    // MARK: ECHOCodable
    
    public func toData() -> Data? {
        
        if let source = source,
            let destination = destination,
            let byteMessage = byteMessage {
            
            var data = Data()
            data.append(optional: Data.fromInt8(1))
            data.append(optional: source.toData())
            data.append(optional: destination.toData())
            data.append(optional: nonceToData(nonce))
            data.append(optional: Data.fromUIntLikeUnsignedByteArray(UInt(byteMessage.count)))
            data.append(optional: byteMessage)
            
            return data
        }
        
        if let byteMessage = byteMessage {
            var data = Data()
            data.append(optional: Data.fromInt8(1))
            data.append(optional: Data.fromInt8(0))
            data.append(optional: Data.fromInt8(0))
            data.append(optional: nonceToData(0))
            data.append(optional: Data.fromUIntLikeUnsignedByteArray(UInt(byteMessage.count)))
            data.append(optional: byteMessage)
            
            return data
        }
        
        return Data(count: 1)
    }
    
    func nonceToData(_ nonce: UInt) -> Data {
        
        var paddedNonceBytes = Data(count: 8)
        var originalNonceBytes = Data(from: nonce)
        
        paddedNonceBytes[0..<8] = originalNonceBytes[8-originalNonceBytes.count..<originalNonceBytes.count]
        
        return paddedNonceBytes
    }
    
    public func toJSON() -> Any? {
        
        let dictionary: [AnyHashable: Any?] = [MemoCodingKeys.fromAccount.rawValue: source?.toJSON(),
                                               MemoCodingKeys.toAccount.rawValue: destination?.toJSON(),
                                               MemoCodingKeys.nonce.rawValue: nonce,
                                               MemoCodingKeys.message.rawValue: byteMessage?.hex]
        
        return dictionary
    }
}
