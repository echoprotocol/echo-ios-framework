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
    
    func login(name: String, password: String, completion: Completion<UserAccount>) {
        
        services.databaseService.getFullAccount(nameOrIds: [name]) { (result) in
            print(result)
        }
    }
    
    func changePassword(old: String, new: String, name: String, completion: Completion<UserAccount>) {
        
    }
}
