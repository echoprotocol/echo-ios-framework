//
//  JsonSerializable.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

protocol JSONCodable: JSONDecodable, JSONEncodable { }

protocol JSONDecodable {
    func toObject<T>(from string: String, type: T.Type) -> T? where T: Decodable
    func toObject<T>(from data: Data, type: T.Type) -> T? where T: Decodable
}

extension JSONDecodable {
    
    func toObject<T>(from string: String, type: T.Type) -> T? where T: Decodable {
        let object = string.data(using: .utf8)
            .flatMap {try? JSONDecoder().decode(type, from: $0)}
        return object
    }
    
    func toObject<T>(from data: Data, type: T.Type) -> T? where T: Decodable {
        let object = try? JSONDecoder().decode(type, from: data)
        return object
    }
}

protocol JSONEncodable {
    func toJSON() -> Any?
    func toJSON() -> String?
}

extension JSONEncodable {
    
    func toJSON() -> String? {
        
        let json: Any? = toJSON()
        let jsonString = (json as?  [AnyHashable: Any?])
            .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: [])}
            .flatMap { String(data: $0, encoding: .utf8)}
        
        return jsonString
    }
}

protocol BytesCodable: BytesDecodable, BytesEncodable { }

protocol BytesDecodable { }

protocol BytesEncodable {
    func toData() -> Data?
}

protocol ECHOCodable: JSONCodable, BytesCodable { }

typealias IntOrStrings = [IntOrString]

public enum IntOrString: Codable, Equatable {
    
    case integer(Int)
    case string(String)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Int.self) {
            self = .integer(value)
            return
        }
        if let value = try? container.decode(String.self) {
            self = .string(value)
            return
        }
        throw DecodingError.typeMismatch(IntOrString.self,
                                         DecodingError.Context(codingPath: decoder.codingPath,
                                                               debugDescription: "Wrong type for IntOrString"))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        }
    }
}
