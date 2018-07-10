//
//  GetAccountHistorySocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

//struct GetAccountHistorySocketOperation: SocketOperation {
//    
//    var method: SocketOperationType
//    var operationId: Int
//    var apiId: Int
//    var completion: Completion<OperationResult<Any>>
//    var accountsIds: [String]
//    var shoudSubscribe: Bool
//    
//    init(accountsIds: [String],
//         subscribe: Bool,
//         method: SocketOperationType,
//         operationId: Int,
//         completion: @escaping Completion<OperationResult<Any>>) {
//        
//        self.accountsIds = accountsIds
//        self.shoudSubscribe = subscribe
//        self.method = method
//        self.operationId = operationId
//        self.apiId = 1
//        self.completion = completion
//    }
//    
//    func createParameters() -> [Any] {
//        let array: [Any] = [apiId,
//                            SocketOperationKeys.fullAccount.rawValue,
//                            [accountsIds, shoudSubscribe]]
//        return array
//    }
//}
