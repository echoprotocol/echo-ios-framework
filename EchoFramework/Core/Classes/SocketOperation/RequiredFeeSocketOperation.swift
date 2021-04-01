//
//  RequiredFeeSocketOperation.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Represents blockchain call. Returns list of AssetAmount for operations
 
    - Return: [[AssetAmount](AssetAmount)]
 */
struct RequiredFeeSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var operations: [BaseOperation]
    var asset: Asset
    var completion: Completion<[FeeType]>
    
    func createParameters() -> [Any] {
        
        let assetId = asset.id
        var operations = [Any?]()
        
        for operation in self.operations {
            operations.append(operation.toJSON())
        }
        
        let array: [Any] = [apiId,
                            SocketOperationKeys.requiredFee.rawValue,
                            [operations, assetId]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            
            switch response.response {
            case .error(let error):
                let result = Result<[FeeType], ECHOError>(error: ECHOError.internalError(error))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let array):
                    
                    var resultArray = [FeeType]()
                    for fee in array {
                        let data = try JSONSerialization.data(withJSONObject: fee, options: [])
                        if let asset = try? JSONDecoder().decode(AssetAmount.self, from: data) {
                            resultArray.append(.defaultFee(asset))
                            continue
                        }
                        
                        if let callContractFee = try? JSONDecoder().decode(CallContractFee.self, from: data) {
                            resultArray.append(.callContractFee(callContractFee))
                            continue
                        }
                        
                        let result = Result<[FeeType], ECHOError>(error: ECHOError.encodableMapping)
                        completion(result)
                        return
                    }
                    
                    let result = Result<[FeeType], ECHOError>(value: resultArray)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[FeeType], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd(error: ECHOError) {
        let result = Result<[FeeType], ECHOError>(error: error)
        completion(result)
    }
}
