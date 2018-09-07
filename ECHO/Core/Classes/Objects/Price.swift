//
//  Price.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    The price struct stores asset prices in the Graphene system.

    A price is defined as a ratio between two assets, and represents a possible
    exchange rate between those two assets. prices are generally not stored in any simplified form,
    i.e. a price of (1000 CORE)/(20 USD) is perfectly normal.
 
    The assets within a price are labeled base and quote. Throughout the Graphene code base, the convention
    used is that the base asset is the asset being sold, and the quote asset is the asset being purchased,
    where the price is represented as base/quote, so in the example price above the seller is looking to sell
    CORE asset and get USD in return.

    - Note: Taken from the Graphene doxygen.
 
    [Memo model documentations](https://dev-doc.myecho.app/structgraphene_1_1chain_1_1price.html)
 */

public struct Price: ECHOCodable, Decodable {
    
    enum PriceCodingKeys: String, CodingKey {
        case base
        case quote
    }
    
    let base: AssetAmount
    let quote: AssetAmount
    
    public init(base: AssetAmount, quote: AssetAmount) {
        
        self.base = base
        self.quote = quote
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: PriceCodingKeys.self)
        base = try values.decode(AssetAmount.self, forKey: .base)
        quote = try values.decode(AssetAmount.self, forKey: .quote)
    }
    
    // MARK: ECHOCodable
    
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
