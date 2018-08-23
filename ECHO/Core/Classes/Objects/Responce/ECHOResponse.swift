//
//  ECHOResponse.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 22.08.2018.
//

import Foundation

struct ECHOResponse: Decodable {
    
    let id: Int
    let response: ErrorOrResult
    let jsonrpc: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case error
        case result
        case jsonrpc
    }
    
    init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        jsonrpc = try values.decode(String.self, forKey: .jsonrpc)
        
        if let response = try? values.decode(ErrorOrResult.self, forKey: .error) {
            self.response = response
        } else {
            response = try values.decode(ErrorOrResult.self, forKey: .result)
        }
    }
}

struct ECHOResponseError: Decodable {
    
    let code: Int
    let message: String
    
    private enum CodingKeys: String, CodingKey {
        case code
        case message
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decode(Int.self, forKey: .code)
        message = try values.decode(String.self, forKey: .message)
    }
}

enum ECHOResponseResult: Decodable {
    
    case integer(Int)
    case string(String)
    case array([Any])
    case dictionary([String: Any])
    case undefined

    init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(Bool.self) {
            self = .integer(value ? 1: 0)
            return
        }
        
        if let value = try? container.decode(Int.self) {
            self = .integer(value)
            return
        }
        
        if let value = try? container.decode(String.self) {
            self = .string(value)
            return
        }
        
        if let value = try? container.decode(AnyDecodable.self) {
            
            if let value = value.value as? [Any] {
                self = .array(value)
                return
            } else if let value = value.value as? [String: Any] {
                self = .dictionary(value)
                return
            }
        }
        
        self = .undefined
    }
}

enum ErrorOrResult: Decodable {
    
    case error(ECHOResponseError)
    case result(ECHOResponseResult)
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(ECHOResponseError.self) {
            self = .error(value)
            return
        }
        
        if let value = try? container.decode(ECHOResponseResult.self) {
            self = .result(value)
            return
        }
        
        if container.decodeNil() {
            self = .result(.undefined)
            return
        }
        
        throw DecodingError.typeMismatch(ErrorOrResult.self,
                                         DecodingError.Context(codingPath: decoder.codingPath,
                                                               debugDescription: "Wrong type for ErrorOrResult"))
    }
}
