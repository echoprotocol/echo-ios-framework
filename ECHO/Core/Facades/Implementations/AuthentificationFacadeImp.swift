//
//  AuthentificationFacadeImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

struct AuthentificationFacadeServices {
    var databaseService: DatabaseApiService
}

class AuthentificationFacadeImp: AuthentificationFacade {
    
    var services: AuthentificationFacadeServices
    
    init(services: AuthentificationFacadeServices) {
        self.services = services
    }
    
    func login(name: String, password: String, completion: @escaping Completion<UserAccount>) {
        
        services.databaseService.getFullAccount(nameOrIds: [name]) { [weak self] (result) in
            switch result {
            case .success(let userAccount):
                
                if self?.checkAccount(account: userAccount, name: name, password: password) == true {
                    let result = Result<UserAccount, ECHOError>(value: userAccount)
                    completion(result)
                } else {
                    let result = Result<UserAccount, ECHOError>(error: ECHOError.undefined)
                    completion(result)
                }

            case .failure(let error):
                let result = Result<UserAccount, ECHOError>(error: error)
                completion(result)
            }
        }
    }
    
    func changePassword(old: String, new: String, name: String, completion: @escaping Completion<UserAccount>) {
        
    }
    
    fileprivate func checkAccount(account: UserAccount, name: String, password: String) -> Bool {
        guard let keychain = ECHOKeychain(name: name, password: password, type: .owner)  else {
            return false
        }
        
        let key = "TEST" + keychain.publicAddress()
        let matches = account.account.owner.keyAuths.compactMap { $0.first(where: {$0 == IntOrString.string(key)}) }
        return matches.count > 0
    }
}
