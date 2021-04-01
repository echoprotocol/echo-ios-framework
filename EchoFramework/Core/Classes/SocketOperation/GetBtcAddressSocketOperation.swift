//
//  GetBtcAddressSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 28.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Get created Bitcoin addresses for account by ID
 
    - Return: [BtcAddress](BtcAddress)
 */
struct GetBtcAddressSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var accountId: String
    var completion: Completion<BtcAddress?>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.getBtcAddress.rawValue,
                            [accountId]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            
            switch response.response {
            case .error(let error):
                let result = Result<BtcAddress?, ECHOError>(error: ECHOError.internalError(error))
                completion(result)
            case .result(let result):
                
                switch result {
                case .dictionary(let dictionary):
                    let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
                    let address = try JSONDecoder().decode(BtcAddress.self, from: data)
                    let result = Result<BtcAddress?, ECHOError>(value: address)
                    completion(result)
                case .undefined:
                    let result = Result<BtcAddress?, ECHOError>(value: nil)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<BtcAddress?, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<BtcAddress?, ECHOError>(error: error)
        completion(result)
    }
}
