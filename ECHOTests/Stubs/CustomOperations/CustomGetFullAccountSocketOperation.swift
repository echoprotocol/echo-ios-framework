//
//  CustomGetFullAccountSocketOperation.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 19/11/2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import ECHO

class CustomGetFullAccountSocketOperation: CustomSocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var accountsIds: [String]
    var shoudSubscribe: Bool
    var completion: Completion<[String: UserAccount]>
    
    init(accountsIds: [String], completion: @escaping Completion<[String: UserAccount]>) {
        
        method = .call
        operationId = 0
        apiId = 0
        self.accountsIds = accountsIds
        shoudSubscribe = false
        self.completion = completion
    }
    
    func setApiId(_ apiId: Int) {
        
        self.apiId = apiId
    }
    
    func setOperationId(_ operationId: Int) {
        
        self.operationId = operationId
    }
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            "get_full_accounts",
                            [accountsIds, shoudSubscribe]]
                            return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            switch response.response {
            case .error(let error):
                let result = Result<[String: UserAccount], ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let array):
                    
                    var accounts = [String: UserAccount]()
                    
                    for container in array {
                        if let containerArray = container as? [Any],
                            let nameOrId = containerArray[safe: 0] as? String,
                            let fullAccountDict = containerArray[safe: 1] as? [String: Any] {
                            
                            let data = try JSONSerialization.data(withJSONObject: fullAccountDict, options: [])
                            let fullAccount = try JSONDecoder().decode(UserAccount.self, from: data)
                            accounts[nameOrId] = fullAccount
                        } else {
                            fallthrough
                        }
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
    
    func forceEnd() {
        let result = Result<[String: UserAccount], ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
