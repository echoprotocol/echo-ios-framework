//
//  AuthentificationFacadeImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

struct AuthentificationFacadeServices {
    let databaseService: DatabaseApiService
}

class AuthentificationFacadeImp: AuthentificationFacade {
    
    let services: AuthentificationFacadeServices
    let core: CryptoCoreComponent
    
    init(services: AuthentificationFacadeServices, core: CryptoCoreComponent) {
        self.services = services
        self.core = core
    }
    
    func isOwnedBy(name: String, password: String, completion: @escaping Completion<UserAccount>) {
        
        services.databaseService.getFullAccount(nameOrIds: [name], shoudSubscribe: false) { [weak self] (result) in
            switch result {
            case .success(let userAccounts):
                
                guard let account = userAccounts[name] else {
                    let result = Result<UserAccount, ECHOError>(error: ECHOError.resultNotFound)
                    completion(result)
                    return
                }
                
                if self?.checkAccount(account: account, name: name, password: password) == true {
                    let result = Result<UserAccount, ECHOError>(value: account)
                    completion(result)
                } else {
                    let result = Result<UserAccount, ECHOError>(error: ECHOError.invalidCredentials)
                    completion(result)
                }

            case .failure(let error):
                let result = Result<UserAccount, ECHOError>(error: error)
                completion(result)
            }
        }
    }
    
    func changePassword(old: String, new: String, name: String, completion: @escaping Completion<UserAccount>) {
        preconditionFailure("Implementation requred")
    }
    
    fileprivate func checkAccount(account: UserAccount, name: String, password: String) -> Bool {
        
        guard let keychain = ECHOKeychain(name: name, password: password, type: .owner, core: core)  else {
            return false
        }
        
        let key = "ECHO" + keychain.publicAddress()
        let matches = account.account.owner?.keyAuths.compactMap { $0.address.addressString == key }.filter { $0 == true }
        
        if let matches = matches {
            return matches.count > 0
        }
        
        return false
    }
    
    fileprivate func changePassword(account: UserAccount, old: String, new: String, name: String, completion: @escaping Completion<UserAccount> ) {
        preconditionFailure("Implementation requred")
    }
}
