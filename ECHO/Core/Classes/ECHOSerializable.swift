//
//  JsonSerializable.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

protocol JSONCodable: JSONDecodable, JSONEncodable { }

protocol JSONDecodable: Decodable {
    func toObject<T>(from string: String, type: T.Type) -> T? where T: Decodable
    func toObject<T>(from data: Data, type: T.Type) -> T? where T: Decodable
}

protocol JSONEncodable: Encodable {
    func toJSON() -> Any?
    func toJSON() -> String?
}

extension JSONEncodable {
    
    func toJSON() -> Any? {
        
        let jsonEncoder = JSONEncoder()
        let json = (try? jsonEncoder.encode(self))
            .flatMap {try? JSONSerialization.jsonObject(with: $0, options: [])}

        return json
    }
    
    func toJSON() -> String? {
        
        let jsonEncoder = JSONEncoder()
        let json = (try? jsonEncoder.encode(self))
            .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: [])}
            .flatMap { String(data: $0, encoding: .utf8)}
        
        return json
    }
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


