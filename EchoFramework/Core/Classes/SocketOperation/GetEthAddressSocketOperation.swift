//
//  GetEthAddressSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 20/05/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Get created Ethereum addresses for account by ID
 
    - Return: [EthAddress](EthAddress)
 */
struct GetEthAddressSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var accountId: String
    var completion: Completion<EthAddress?>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.getEthAddress.rawValue,
                            [accountId]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            
            switch response.response {
            case .error(let error):
                let result = Result<EthAddress?, ECHOError>(error: ECHOError.internalError(error))
                completion(result)
            case .result(let result):
                
                switch result {
                case .dictionary(let dictionary):
                    let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
                    let address = try JSONDecoder().decode(EthAddress.self, from: data)
                    let result = Result<EthAddress?, ECHOError>(value: address)
                    completion(result)
                case .undefined:
                    let result = Result<EthAddress?, ECHOError>(value: nil)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<EthAddress?, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<EthAddress?, ECHOError>(error: error)
        completion(result)
    }
}
