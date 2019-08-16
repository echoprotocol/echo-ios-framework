//
//  Signatures.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 16/08/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Represents signature model
 */
public struct Signatures: Decodable {
    
    enum SignaturesCodingKeys: String, CodingKey {
        case step = "_step"
        case value = "_value"
        case leader = "_leader"
        case signer = "_signer"
        case delegates = "_delegate"
        case fallback = "_fallback"
        case bbaSign = "_bba_sign"
    }
    
    public let step: IntOrString
    public let value: IntOrString
    public let leader: IntOrString
    public let signer: IntOrString
    public let delegates: IntOrString
    public let fallback: IntOrString
    public let bbaSign: String
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: SignaturesCodingKeys.self)
        step = try values.decode(IntOrString.self, forKey: .step)
        value = try values.decode(IntOrString.self, forKey: .value)
        leader = try values.decode(IntOrString.self, forKey: .leader)
        signer = try values.decode(IntOrString.self, forKey: .signer)
        delegates = try values.decode(IntOrString.self, forKey: .delegates)
        fallback = try values.decode(IntOrString.self, forKey: .fallback)
        bbaSign = try values.decode(String.self, forKey: .bbaSign)
    }
}
