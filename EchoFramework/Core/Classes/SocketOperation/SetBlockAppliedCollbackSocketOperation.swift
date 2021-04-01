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
    var completion: Completion<Void>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.setBlockAppliedCallback.rawValue,
                            [blockId]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        switch response.response {
        case .error(let error):
            let result = Result<Void, ECHOError>(error: ECHOError.internalError(error))
            completion(result)
        case .result:
            let result = Result<Void, ECHOError>(value: ())
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<Void, ECHOError>(error: error)
        completion(result)
    }
}
