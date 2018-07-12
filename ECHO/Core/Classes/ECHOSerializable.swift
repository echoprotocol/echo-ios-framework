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

protocol JSONEncodable {
    func toJSON() -> Any?
    func toJSON() -> String?
}

extension JSONEncodable {
    
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

protocol BytesCodable: BytesDecodable, BytesEncodable { }

protocol BytesDecodable {

}

protocol BytesEncodable: Encodable {
    func toData() -> Data?
}

protocol ECHOCodable: JSONCodable, BytesCodable { }
