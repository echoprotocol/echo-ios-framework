//
//  GetAllContractsSocketOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 10.09.2018.
//

/**
    Retrieves information about all contracts.
 
    - Return: [[ContractInfo](ContractInfo)]
 */
struct GetAllContractsSocketOperation: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var completion: Completion<[ContractInfo]>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.getAllContracts.rawValue,
                            []]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            switch response.response {
            case .error(let error):
                let result = Result<[ContractInfo], ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let array):
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    let contractsInfo = try JSONDecoder().decode([ContractInfo].self, from: data)
                    let result = Result<[ContractInfo], ECHOError>(value: contractsInfo)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<[ContractInfo], ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<[ContractInfo], ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
