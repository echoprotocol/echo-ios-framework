//
//  RevealFacadeImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 13.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct RevealFacadeServices {
    var databaseService: ApiIdentifireHolder
    var cryptoService: ApiIdentifireHolder
    var historyService: ApiIdentifireHolder
    var networkBroadcastService: ApiIdentifireHolder
    var networkNodesService: ApiIdentifireHolder
}

class RevealFacadeImp: RevealApiFacade {
    
    var socketCore: SocketCoreComponent
    var apiOptions: APIOption
    var services: RevealFacadeServices
    fileprivate var error: ECHOError?
    var registrationCompletion: Completion<Bool>?
    
    let dispatchGroup = DispatchGroup()
    
    required init(socketCore: SocketCoreComponent,
                  options: APIOption,
                  services: RevealFacadeServices) {
        apiOptions = options
        self.socketCore = socketCore
        self.services = services
    }
    
    func revealApi(completion: @escaping Completion<Bool>) {
        
        registrationCompletion = completion
        
        socketCore.connect(options: apiOptions) { [weak self] (result) in
            switch result {
            case .success(_):
                self?.loginAndRegister()
            case .failure(let error):
                let error = Result<Bool, ECHOError>(error: error)
                self?.registrationCompletion?(error)
            }
        }
    }
    
    func loginAndRegister() {
        
        let operation = AccessSocketOperation(type: .login, method: .call, operationId: socketCore.nextOperationId()) { [weak self] (result) in
            
            switch result {
            case .success(_):
                self?.registerAPIs()
            case .failure(let error):
                self?.error = error
            }
        }
        
        socketCore.send(operation: operation)
    }
    
    fileprivate func registerAPIs() {
        
        registerAPIs(dispatchGroup, options: apiOptions)
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            
            if let error = self?.error {
                let error = Result<Bool, ECHOError>(error: error)
                self?.registrationCompletion?(error)
            } else {
                let error = Result<Bool, ECHOError>(value: true)
                self?.registrationCompletion?(error)
            }
        }
    }
    
    fileprivate func registerAPIs(_ dispatchGroup: DispatchGroup, options: APIOption) {
        
        if options.contains(.database) {
            registerDatabaseoApi(group: dispatchGroup)
        }
        
        if options.contains(.networkBroadcast) {
            registerNetworkBroadcastApi(group: dispatchGroup)
        }
        
        if options.contains(.accountHistory) {
            registerHistoryApi(group: dispatchGroup)
        }
        
        if options.contains(.crypto) {
            registerCryptoApi(group: dispatchGroup)
        }
        
        if options.contains(.networkNodes) {
            registerNetworkNodesApi(group: dispatchGroup)
        }
    }
    
    fileprivate func registerCryptoApi(group: DispatchGroup) {
        
        group.enter()
        
        let operation = AccessSocketOperation(type: .crypto, method: .call, operationId: socketCore.nextOperationId()) { [weak self] (result) in
            
            switch result {
            case .success(let id):
                self?.services.cryptoService.apiIdentifire = id
            case .failure(let error):
                self?.error = error
            }
            self?.dispatchGroup.leave()
        }
        
        socketCore.send(operation: operation)
    }
    
    fileprivate func registerDatabaseoApi(group: DispatchGroup) {
        
        group.enter()
        
        let operation = AccessSocketOperation(type: .database,
                                              method: .call,
                                              operationId: socketCore.nextOperationId()) { [weak self] (result) in
            
            switch result {
            case .success(let id):
                self?.services.databaseService.apiIdentifire = id
            case .failure(let error):
                self?.error = error
            }
            self?.dispatchGroup.leave()
        }
        
        socketCore.send(operation: operation)
    }
    
    fileprivate func registerHistoryApi(group: DispatchGroup) {
        
        group.enter()
        
        let operation = AccessSocketOperation(type: .history,
                                              method: .call,
                                              operationId: socketCore.nextOperationId()) { [weak self] (result) in
            
            switch result {
            case .success(let id):
                self?.services.historyService.apiIdentifire = id
            case .failure(let error):
                self?.error = error
            }
            self?.dispatchGroup.leave()
        }
        
        socketCore.send(operation: operation)
    }
    
    fileprivate func registerNetworkBroadcastApi(group: DispatchGroup) {
        group.enter()
        
        let operation = AccessSocketOperation(type: .networkBroadcast,
                                              method: .call,
                                              operationId: socketCore.nextOperationId()) { [weak self] (result) in
            
            switch result {
            case .success(let id):
                self?.services.networkBroadcastService.apiIdentifire = id
            case .failure(let error):
                self?.error = error
            }
            self?.dispatchGroup.leave()
        }
        
        socketCore.send(operation: operation)
    }
    
    fileprivate func registerNetworkNodesApi(group: DispatchGroup) {
        group.enter()
        
        let operation = AccessSocketOperation(type: .networkBroadcast,
                                              method: .call,
                                              operationId: socketCore.nextOperationId()) { [weak self] (result) in
            
            switch result {
            case .success(let id):
                self?.services.networkNodesService.apiIdentifire = id
            case .failure(let error):
                self?.error = error
            }
            self?.dispatchGroup.leave()
        }
        
        socketCore.send(operation: operation)
    }
}
