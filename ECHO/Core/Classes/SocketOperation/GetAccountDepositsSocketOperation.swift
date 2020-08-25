//
//  GetAccountDepositsSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 11/06/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
    Returns all approved deposits, for the given account id
 
    - Return: [[EthDeposit]](EthDeposit)
 */
struct GetAccountDepositsSocketOperation: SocketOperation {
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var accountId: String
    var type: SidechainType?
    var completion: Completion<[SidechainDepositEnum]>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.getAccountDeposits.rawValue,
                            [accountId, type?.rawValue ?? String()]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            switch response.response {
            case .error(let error):
                let result = Result<[SidechainDepositEnum], ECHOError>(error: ECHOError.internalError(error))
                completion(result)
            case .result(let result):
                switch result {
                case .array(let array):
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let deposits = try JSONDecoder().decode([SidechainDepositEnum].self, from: data)
                    let result = Result<[SidechainDepositEnum], ECHOError>(value: deposits)
                    completion(result)
                    
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[SidechainDepositEnum], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<[SidechainDepositEnum], ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
