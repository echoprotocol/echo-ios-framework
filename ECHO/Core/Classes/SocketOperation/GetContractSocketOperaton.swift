//
//  GetContractSocketOperaton.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 10.09.2018.
//

/**
    Retrieves full information about contract.
 
    - Return: [ContractStructEVM](ContractStructEVM)
 */
struct GetContractSocketOperaton: SocketOperation {
    
    var method: SocketOperationType
    var operationId: Int
    var apiId: Int
    var contractId: String
    var completion: Completion<ContractStructEnum>
    
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
                let result = Result<ContractStructEnum, ECHOError>(error: ECHOError.internalError(error.message))
                completion(result)
            case .result(let result):
                
                switch result {
                case .array(let arr):
                    let data = try JSONSerialization.data(withJSONObject: arr, options: [])
                    let contractStruct = try JSONDecoder().decode(ContractStructEnum.self, from: data)
                    let result = Result<ContractStructEnum, ECHOError>(value: contractStruct)
                    completion(result)
                default:
                    throw ECHOError.encodableMapping
                }
            }
        } catch {
            let result = Result<ContractStructEnum, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
    }
    
    func forceEnd() {
        let result = Result<ContractStructEnum, ECHOError>(error: ECHOError.connectionLost)
        completion(result)
    }
}
