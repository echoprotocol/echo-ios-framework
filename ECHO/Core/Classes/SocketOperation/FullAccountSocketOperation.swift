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
    var completion: Completion<UserAccount>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.fullAccount.rawValue,
                            [accountsIds, shoudSubscribe]]
        return array
    }
    
    func complete(json: [String: Any]) {
        
        let result = (json["result"] as? [Any])
            .flatMap { $0[safe: 0] as? [Any]}
            .flatMap { $0[safe: 1] as? [String: Any]}
            .flatMap { try? JSONSerialization.data(withJSONObject: $0, options: []) }
            .flatMap { try? JSONDecoder().decode(UserAccount.self, from: $0) }
            .flatMap { Result<UserAccount, ECHOError>(value: $0) }
        
        if let result = result {
            completion(result)
        } else {
            let result = Result<UserAccount, ECHOError>(error: ECHOError.undefined)
            completion(result)
        }
    }
}
