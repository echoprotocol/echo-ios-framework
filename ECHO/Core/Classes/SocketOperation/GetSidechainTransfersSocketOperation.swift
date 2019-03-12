//
//  GetSidechainTransfersSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 11/03/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
 Retrieve all sidechain transfers for ETH Address
 
 - Return: [[SidechainTransfer]](SidechainTransfer)
 */
struct GetSidechainTransfersSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var ethAddress: String
    var completion: Completion<[SidechainTransfer]>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.getSidechainTransfers.rawValue,
                            [ethAddress]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            switch response.response {
            case .error(let error):
                let result = Result<[SidechainTransfer], ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let array):
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let transfers = try JSONDecoder().decode([SidechainTransfer].self, from: data)
                    let result = Result<[SidechainTransfer], ECHOError>(value: transfers)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[SidechainTransfer], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<[SidechainTransfer], ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}

