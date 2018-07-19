//
//  InformationFacadeImp.swift
//  BitcoinKit
//
//  Created by Fedorenko Nikita on 19.07.2018.
//

struct InformationFacadeServices {
    var databaseService: DatabaseApiService
}

class InformationFacadeImp: InformationFacade {
    
    var services: InformationFacadeServices
    
    init(services: InformationFacadeServices) {
        self.services = services
    }
    
    func getAccount(nameOrID: String, completion: @escaping Completion<Account>) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrID]) { (result) in
            switch result {
            case .success(let userAccount):
                let result = Result<Account, ECHOError>(value: userAccount.account)
                completion(result)
            case .failure(let error):
                let result = Result<Account, ECHOError>(error: error)
                completion(result)
            }
        }
    }
    
    func isAccauntReserved(nameOrID: String, completion: @escaping Completion<Bool>) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrID]) { (result) in
            switch result {
            case .success(_):
                let result = Result<Bool, ECHOError>(value: true)
                completion(result)
            case .failure(_):
                let result = Result<Bool, ECHOError>(value: false)
                completion(result)
            }
        }
    }
    
    func getBalance(nameOrID: String, asset: String?, completion: @escaping Completion<[AccountBalance]>) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrID]) { (result) in
            switch result {
            case .success(let userAccount):
                
                let balances: [AccountBalance]
                
                if let asset = asset {
                    balances = userAccount.balances.filter {$0.assetType == asset }
                } else {
                    balances =  userAccount.balances
                }
                
                let result = Result<[AccountBalance], ECHOError>(value: balances)
                completion(result)
            case .failure(let error):
                let result = Result<[AccountBalance], ECHOError>(error: error)
                completion(result)
            }
        }
    }
}
