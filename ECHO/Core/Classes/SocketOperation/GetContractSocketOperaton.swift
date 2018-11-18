//
//  GetContractSocketOperaton.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 10.09.2018.
//

/**
    Retrieves full information about contract.
 
    - Return: [ContractStruct](ContractStruct)
 */
struct GetContractSocketOperaton: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var contractId: String
    var completion: Completion<ContractStruct>
    
    func createParameters() -> [Any] {
        let array: [Any] = [apiId,
                            SocketOperationKeys.getContract.rawValue,
                            [contractId]]
        return array
    }
    
    func handleResponse(_ response: ECHODirectResponse) {
        
        do {
            
            switch response.response {
            case .error(let error):
                let result = Result<ContractStruct, ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .dictionary(let dict):
                    let data = try JSONSerialization.data(withJSONObject: dict, options: [])
                    let contractStruct = try JSONDecoder().decode(ContractStruct.self, from: data)
                    let result = Result<ContractStruct, ECHOError>(value: contractStruct)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<ContractStruct, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<ContractStruct, ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
