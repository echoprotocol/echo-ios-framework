//
//  SubmitRegistrationSolutionSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 16.10.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
   Submit PoW task solution to register account

   - Return: [Bool](Bool)
*/
struct SubmitRegistrationSolutionSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var name: String
    var activeKey: String
    var echorandKey: String
    var nonce: UInt
    var randNum: UInt
    var completion: Completion<Bool>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.submitRegistrationSolution.rawValue,
                            [operationId, name, activeKey, echorandKey, nonce, randNum]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            switch response.response {
            case .error(let error):
                let result = Result<Bool, ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .integer(let int):
                    let bool = int == 1
                    let result = Result<Bool, ECHOError>(value: bool)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<Bool, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<Bool, ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
