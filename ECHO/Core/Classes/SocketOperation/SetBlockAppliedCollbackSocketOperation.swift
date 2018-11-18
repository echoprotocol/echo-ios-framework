//
//  SetBlockAppliedCollbackSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 04/10/2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct SetBlockAppliedCollbackSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var blockId: String
    var completion: Completion<Bool>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.setBlockAppliedCallback.rawValue,
                            [blockId]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        switch response.response {
        case .error(let error):
            let result = Result<Bool, ECHOError>(error: ECHOError.internalError(error.message))
            completion(result)
        case .result(_):
            let result = Result<Bool, ECHOError>(value: true)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<Bool, ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
