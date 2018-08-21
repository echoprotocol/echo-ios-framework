//
//  Price.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct Price: ECHOCodable, Decodable {
    
    enum PriceCodingKeys: String, CodingKey {
        case base
        case quote
    }
    
    var base: AssetAmount
    var quote: AssetAmount
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: PriceCodingKeys.self)
        base = try values.decode(AssetAmount.self, forKey: .base)
        quote = try values.decode(AssetAmount.self, forKey: .quote)
    }
    
    // MARK: ECHOCodable
    
    func toJSON() -> String? {
        
        let json: Any? = toJSON()
        let jsonString = (json as?  [AnyHashable: Any?])
            .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: [])}
            .flatMap { String(data: $0, encoding: .utf8)}
        
        return jsonString
    }
    
    func toJSON() -> Any? {
        
        let dictionary: [AnyHashable: Any?] = [PriceCodingKeys.base.rawValue: base.toJSON(),
                                               PriceCodingKeys.quote.rawValue: quote.toJSON()]
        
        return dictionary
    }
    
    func toData() -> Data? {
        
        var data = Data()
        data.append(optional: base.toData())
        data.append(optional: quote.toData())
        return data
    }
}
