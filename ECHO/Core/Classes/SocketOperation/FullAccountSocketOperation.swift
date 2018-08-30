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
    var completion: Completion<[String: UserAccount]>
    
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
                let result = Result<[String: UserAccount], ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let array):
                    
                    var accounts = [String: UserAccount]()
                    var findedEncodeError = false
                    
                    for container in array {
                        if let containerArray = container as? [Any],
                            let nameOrId = containerArray[safe: 0] as? String,
                            let fullAccountDict = containerArray[safe: 1] as? [String: Any] {
                            
                            let data = try JSONSerialization.data(withJSONObject: fullAccountDict, options: [])
                            let fullAccount = try JSONDecoder().decode(UserAccount.self, from: data)
                            accounts[nameOrId] = fullAccount
                        } else {
                            findedEncodeError = true
                            break
                        }
                    }
                    
                    if findedEncodeError {
                        fallthrough
                    }

                    let result = Result<[String: UserAccount], ECHOError>(value: accounts)
                    completion(result)

                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[String: UserAccount], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
}
