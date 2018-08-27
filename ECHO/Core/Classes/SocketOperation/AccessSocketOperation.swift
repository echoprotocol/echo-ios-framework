//
//  AccessSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

enum AccessSocketOperationType: String {
    case login
    case database
    case networkBroadcast = "network_broadcast"
    case networkNodes = "network_node"
    case history
    case crypto
}

struct AccessSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var completion: Completion<Int>
    var type: AccessSocketOperationType
    
    init(type: AccessSocketOperationType,
         method: SocketOperationType,
         operationId: Int,
         completion: @escaping Completion<Int>) {
        
        self.type = type
        self.method = method
        self.operationId = operationId
        self.apiId = 1
        self.completion = completion
    }
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            type.rawValue,
                            getArrayForParams()]
        return array
    }
    
    fileprivate func getArrayForParams() -> [Any] {
        switch type {
        case .login:
            return ["", ""]
        case .crypto, .history, .database, .networkBroadcast, .networkNodes:
            return []
        }
    }
    
    func complete(json: [String: Any]) {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let response = try JSONDecoder().decode(ECHOResponse.self, from: data)
            
            switch response.response {
            case .error(let error):
                let result = Result<Int, ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .integer(let id):
                    let result = Result<Int, ECHOError>(value: id)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<Int, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<Int, ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
