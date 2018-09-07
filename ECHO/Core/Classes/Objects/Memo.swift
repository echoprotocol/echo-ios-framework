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
struct Memo: ECHOCodable, Decodable {
    
    enum MemoCodingKeys: String, CodingKey {
        case fromAccount = "from"
        case toAccount = "to"
        case nonce
        case message
    }
    
    let nonceRadix: Int = 10
    let paddedNonceArraySize: Int = 8
    
    var source: Address?
    var destination: Address?
    let nonce: Int
    var byteMessage: Data?
    var plaintextMessage: String?
    
    init() {
        nonce = 0
    }
    
    init(source: Address?, destination: Address?, nonce: Int, byteMessage: Data?) {
        
        self.source = source
        self.destination = destination
        self.nonce = nonce
        self.byteMessage = byteMessage
    }
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: MemoCodingKeys.self)
        
        let fromAddress = try? values.decode(String.self, forKey: .fromAccount)
        let toAddress = try? values.decode(String.self, forKey: .toAccount)
        if let fromAddress = fromAddress { source = Address(fromAddress, data: nil) }
        if let toAddress = toAddress { destination = Address(toAddress, data: nil) }
        
        let nonceValue = try? values.decode(Int.self, forKey: .nonce)
        nonce = nonceValue ?? 0
        
        byteMessage = try values.decode(Data.self, forKey: .message)
    }
    
    // MARK: ECHOCodable
    
    func toData() -> Data? {
        
        if let source = source,
            let destination = destination,
            let byteMessage = byteMessage {
            
            var data = Data()
            data.append(optional: Data.fromInt8(1))
            data.append(optional: source.toData())
            data.append(optional: destination.toData())
            data.append(optional: Data.fromInt64(nonce))
            data.append(optional: Data.fromInt8(byteMessage.count))
            data.append(optional: byteMessage)
            
            return data
        }
        
        if let byteMessage = byteMessage {
            var data = Data()
            data.append(optional: Data.fromInt8(1))
            data.append(optional: Data.fromInt8(0))
            data.append(optional: Data.fromInt8(0))
            data.append(optional: Data.fromInt8(0))
            data.append(optional: Data.fromInt8(byteMessage.count))
            data.append(optional: byteMessage)
            
            return data
        }
        
        return Data(count: 1)
    }
    
    func toJSON() -> Any? {
        
        let dictionary: [AnyHashable: Any?] = [MemoCodingKeys.fromAccount.rawValue: source?.toJSON(),
                                               MemoCodingKeys.toAccount.rawValue: destination?.toJSON(),
                                               MemoCodingKeys.nonce.rawValue: nonce,
                                               MemoCodingKeys.message.rawValue: byteMessage?.hex]
        
        return dictionary
    }
}
