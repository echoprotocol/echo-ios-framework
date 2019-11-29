//
//  RequestRegistrationTaskSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 16.10.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
   Get PoW task to register account

   - Return: [RegistrationTask](RegistrationTask)
*/
struct RequestRegistrationTaskSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var completion: Completion<RegistrationTask>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.requestRegistrationTask.rawValue,
                            []]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            switch response.response {
            case .error(let error):
                let result = Result<RegistrationTask, ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .dictionary(let dict):
                    let data = try JSONSerialization.data(withJSONObject: dict, options: [])
                    let block = try JSONDecoder().decode(RegistrationTask.self, from: data)
                    let result = Result<RegistrationTask, ECHOError>(value: block)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<RegistrationTask, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<RegistrationTask, ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}

