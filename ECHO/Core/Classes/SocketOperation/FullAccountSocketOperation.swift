//
//  FullAccountSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct FullAccountSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var accountsIds: [String]
    var shoudSubscribe: Bool
    var completion: Completion<[UserAccount]>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.fullAccount.rawValue,
                            [accountsIds, shoudSubscribe]]
        return array
    }
    
    func complete(json: [String: Any]) {
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let response = try JSONDecoder().decode(ECHOResponse.self, from: data)
            
            switch response.response {
            case .error(let error):
                let result = Result<[UserAccount], ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let array):
                    
                    var accounts = [UserAccount]()
                    var findedEncodeError = false
                    
                    for container in array {
                        if let containerArray = container as? [Any],
                            let fullAccountDict = containerArray[safe: 1] as? [String: Any] {
                            
                            let data = try JSONSerialization.data(withJSONObject: fullAccountDict, options: [])
                            let fullAccount = try JSONDecoder().decode(UserAccount.self, from: data)
                            accounts.append(fullAccount)
                        } else {
                            findedEncodeError = true
                            break
                        }
                    }
                    
                    if findedEncodeError {
                        fallthrough
                    }

                    let result = Result<[UserAccount], ECHOError>(value: accounts)
                    completion(result)

                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch let error {
            let result = Result<[UserAccount], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<[UserAccount], ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
