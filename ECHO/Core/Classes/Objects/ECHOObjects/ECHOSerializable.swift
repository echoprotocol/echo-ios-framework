//
//  JsonSerializable.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Protocol which contains logic of [JSONDecodable](JSONDecodable), [JSONEncodable](JSONEncodable)
 */
public protocol JSONCodable: JSONDecodable, JSONEncodable { }

/**
    Decode object form JSON
 */
public protocol JSONDecodable {
    func toObject<T>(from string: String, type: T.Type) -> T? where T: Decodable
    func toObject<T>(from data: Data, type: T.Type) -> T? where T: Decodable
}

extension JSONDecodable {
    
    public func toObject<T>(from string: String, type: T.Type) -> T? where T: Decodable {
        let object = string.data(using: .utf8)
            .flatMap {try? JSONDecoder().decode(type, from: $0)}
        return object
    }
    
    public func toObject<T>(from data: Data, type: T.Type) -> T? where T: Decodable {
        let object = try? JSONDecoder().decode(type, from: data)
        return object
    }
}

/**
    Encode object to JSON
 */
public protocol JSONEncodable {
    func toJSON() -> Any?
    func toJSON() -> String?
}

extension JSONEncodable {
    
    public func toJSON() -> String? {
        
        let json: Any? = toJSON()
        let jsonString = (json as?  [AnyHashable: Any?])
            .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: [])}
            .flatMap { String(data: $0, encoding: .utf8)}
        
        return jsonString
    }
}

/**
    Protocol which contains logic of [BytesDecodable](BytesDecodable), [BytesEncodable](BytesEncodable)
 */
public protocol BytesCodable: BytesDecodable, BytesEncodable { }

/**
    Decode object from Data
 */
public protocol BytesDecodable { }

/**
    Encode object to Data
 */
public protocol BytesEncodable {
    func toData() -> Data?
}

/**
    Protocol which contains logic of [JSONCodable](JSONCodable), [BytesCodable](BytesCodable)
 */
public protocol ECHOCodable: JSONCodable, BytesCodable { }

/**
    Array of [IntOrString](IntOrString)
 */
public typealias IntOrStrings = [IntOrString]

/**
    Enum which contains int or string value from decoded object
 */
public enum IntOrString: Codable, Equatable {
    
    case integer(Int)
    case string(String)
    
    var stringValue: String {
        switch self {
        case .integer(let int):
            return String(int)
        case .string(let string):
            return string
        }
    }
    
    var intValue: Int {
        switch self {
        case .integer(let int):
            return int
        case .string(let string):
            return Int(string) ?? 0
        }
    }
    
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

/**
    Array of [IntOrDict](IntOrDict)
 */
public typealias IntOrDicts = [IntOrDict]

/**
    Enum which contains int or dict value from decoded object
 */
public enum IntOrDict: Codable, Equatable {
    
    case integer(Int)
    case dict([String: IntOrString])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Int.self) {
            self = .integer(value)
            return
        }
        if let value = try? container.decode([String: IntOrString].self) {
            self = .dict(value)
            return
        }
        throw DecodingError.typeMismatch(IntOrDict.self,
                                         DecodingError.Context(codingPath: decoder.codingPath,
                                                               debugDescription: "Wrong type for IntOrDict"))
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let value):
            try container.encode(value)
        case .dict(let value):
            try container.encode(value)
        }
    }
}
