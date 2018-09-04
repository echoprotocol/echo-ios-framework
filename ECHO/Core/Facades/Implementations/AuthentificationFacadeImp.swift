//
//  AuthentificationFacadeImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//

struct AuthentificationFacadeServices {
    let databaseService: DatabaseApiService
    let networkBroadcastService: NetworkBroadcastApiService
}

/**
    Implementation of [AuthentificationFacade](AuthentificationFacade) 
 */
final public class AuthentificationFacadeImp: AuthentificationFacade, ECHOQueueble {
    
    var queues: [ECHOQueue]
    let services: AuthentificationFacadeServices
    let core: CryptoCoreComponent
    let network: Network
    
    init(services: AuthentificationFacadeServices, core: CryptoCoreComponent, network: Network) {
        self.services = services
        self.core = core
        self.network = network
        self.queues = [ECHOQueue]()
    }
    
    public func isOwnedBy(name: String, password: String, completion: @escaping Completion<UserAccount>) {
        
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
    
    fileprivate enum ChangePasswordKeys: String {
        case account
        case operation
        case fee
        case blockData
        case chainId
        case transaciton
    }
    
    public func changePassword(old: String, new: String, name: String, completion: @escaping Completion<Bool>) {
        
        let changePasswordQueue = ECHOQueue()
        queues.append(changePasswordQueue)
        
        let checkAccountOperation = createCheckAccountOperation(changePasswordQueue, name, old, completion)
        let accountUpdateOperation = createAccountUpdateOperation(changePasswordQueue, name, new, completion)
        let getRequiredFee = createGetRequiredFeeOperation(changePasswordQueue, completion)
        let getChainIdOperation = createChainIdOperation(changePasswordQueue, completion)
        let getBlockDataOperation = createGetBlockDataOperation(changePasswordQueue, completion)
        let bildTransacitonOperation = createBildTransactionOperation(changePasswordQueue, old, completion)
        let sendUpdateOperation = createSendUpdateOperation(changePasswordQueue, completion)
        let lastOperation = createLastOperation(queue: changePasswordQueue)
        
        changePasswordQueue.addOperation(checkAccountOperation)
        changePasswordQueue.addOperation(accountUpdateOperation)
        changePasswordQueue.addOperation(getRequiredFee)
        changePasswordQueue.addOperation(getChainIdOperation)
        changePasswordQueue.addOperation(getBlockDataOperation)
        changePasswordQueue.addOperation(bildTransacitonOperation)
        changePasswordQueue.addOperation(sendUpdateOperation)
        changePasswordQueue.addOperation(lastOperation)
    }
    
    fileprivate func createCheckAccountOperation(_ queue: ECHOQueue,
                                                 _ name: String,
                                                 _ password: String,
                                                 _ completion: @escaping Completion<Bool>) -> Operation {
        
        let checkAccountOperation = BlockOperation()
        
        checkAccountOperation.addExecutionBlock { [weak checkAccountOperation, weak self, weak queue] in
            
            guard checkAccountOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            
            self?.isOwnedBy(name: name, password: password, completion: { (result) in
                switch result {
                case .success(let account):
                    queue?.saveValue(account, forKey: ChangePasswordKeys.account.rawValue)
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<Bool, ECHOError>(error: error)
                    completion(result)
                }
                
                queue?.startNextOperation()
            })
            
            queue?.waitStartNextOperation()
        }
        
        return checkAccountOperation
    }
    
    fileprivate func createAccountUpdateOperation(_ queue: ECHOQueue,
                                                  _ name: String,
                                                  _ newPassword: String,
                                                  _ completion: @escaping Completion<Bool>) -> Operation {
        
        let accountUpdateOperation = BlockOperation()
        
        accountUpdateOperation.addExecutionBlock { [weak accountUpdateOperation, weak self, weak queue] in
            
            guard accountUpdateOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let cryptoCore = self?.core else { return }
            guard let network = self?.network else { return }
            guard let account: UserAccount = queue?.getValue(ChangePasswordKeys.account.rawValue) else { return }
            
            guard let addressContainer = AddressKeysContainer(login: name, password: newPassword, core: cryptoCore) else {
                queue?.cancelAllOperations()
                let result = Result<Bool, ECHOError>(error: ECHOError.invalidCredentials)
                completion(result)
                return
            }
            
            let memoAddressString = network.prefix.rawValue + addressContainer.memoKeychain.publicAddress()
            let activeAddressString = network.prefix.rawValue + addressContainer.activeKeychain.publicAddress()
            let ownerAddressString = network.prefix.rawValue + addressContainer.ownerKeychain.publicAddress()
            
            let memoAddress = Address(memoAddressString, data: addressContainer.memoKeychain.publicKey())
            let activeAddress = Address(activeAddressString, data: addressContainer.activeKeychain.publicKey())
            let ownerAddress = Address(ownerAddressString, data: addressContainer.ownerKeychain.publicKey())
            
            let activeKeyAddressAuth = AddressAuthority(address: activeAddress, value: 1)
            let ownerKeyAddressAuth = AddressAuthority(address: ownerAddress, value: 1)
            
            let activeAuthority = Authority(weight: 1, keyAuth: [activeKeyAddressAuth], accountAuth: [])
            let ownerAuthority = Authority(weight: 1, keyAuth: [ownerKeyAddressAuth], accountAuth: [])
            let options = AccountOptions(memo: memoAddress, votingAccount: nil)
            
            let fee = AssetAmount(amount: 0, asset: Asset(Settings.defaultAsset))
            
            let operation = AccountUpdateOperation(account: account.account,
                                                   owner: ownerAuthority,
                                                   active: activeAuthority,
                                                   options: options,
                                                   fee: fee)
            
            queue?.saveValue(operation, forKey: ChangePasswordKeys.operation.rawValue)
        }
        
        return accountUpdateOperation
    }
    
    fileprivate func createGetRequiredFeeOperation(_ queue: ECHOQueue,
                                                   _ completion: @escaping Completion<Bool>) -> Operation {
        
        let getRequiredFee = BlockOperation()
        
        getRequiredFee.addExecutionBlock { [weak getRequiredFee, weak queue, weak self] in
            
            guard getRequiredFee?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let operation: AccountUpdateOperation = queue?.getValue(ChangePasswordKeys.operation.rawValue) else { return }
            
            let asset = Asset(Settings.defaultAsset)
            
            self?.services.databaseService.getRequiredFees(operations: [operation], asset: asset, completion: { (result) in
                switch result {
                case .success(let fees):
                    if let fee = fees.first {
                        queue?.saveValue(fee, forKey: ChangePasswordKeys.fee.rawValue)
                    } else {
                        queue?.cancelAllOperations()
                        let result = Result<Bool, ECHOError>(error: ECHOError.resultNotFound)
                        completion(result)
                    }
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<Bool, ECHOError>(error: error)
                    completion(result)
                }
                
                queue?.startNextOperation()
            })
            
            queue?.waitStartNextOperation()
        }
        
        return getRequiredFee
    }
    
    fileprivate func createGetBlockDataOperation(_ queue: ECHOQueue,
                                                 _ completion: @escaping Completion<Bool>) -> Operation {
        
        let getBlockDataOperation = BlockOperation()
        
        getBlockDataOperation.addExecutionBlock { [weak getBlockDataOperation, weak queue, weak self] in
            
            guard getBlockDataOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            
            self?.services.databaseService.getBlockData(completion: { (result) in
                switch result {
                case .success(let blockData):
                    queue?.saveValue(blockData, forKey: ChangePasswordKeys.blockData.rawValue)
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<Bool, ECHOError>(error: error)
                    completion(result)
                }
                
                queue?.startNextOperation()
            })
            
            queue?.waitStartNextOperation()
        }
        
        return getBlockDataOperation
    }
    
    fileprivate func createChainIdOperation(_ queue: ECHOQueue,
                                            _ completion: @escaping Completion<Bool>) -> Operation {
        
        let chainIdOperation = BlockOperation()
        
        chainIdOperation.addExecutionBlock { [weak chainIdOperation, weak queue, weak self] in
            
            guard chainIdOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            
            self?.services.databaseService.getChainId(completion: { (result) in
                switch result {
                case .success(let chainId):
                    queue?.saveValue(chainId, forKey: ChangePasswordKeys.chainId.rawValue)
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<Bool, ECHOError>(error: error)
                    completion(result)
                }
                
                queue?.startNextOperation()
            })
            
            queue?.waitStartNextOperation()
        }
        
        return chainIdOperation
    }
    
    fileprivate func createBildTransactionOperation(_ queue: ECHOQueue,
                                                    _ password: String,
                                                    _ completion: @escaping Completion<Bool>) -> Operation {
        
        let bildTransferOperation = BlockOperation()
        
        bildTransferOperation.addExecutionBlock { [weak bildTransferOperation, weak queue, weak self] in
            
            guard bildTransferOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            
            guard let account: UserAccount = queue?.getValue(ChangePasswordKeys.account.rawValue) else { return }
            guard var operation: AccountUpdateOperation = queue?.getValue(ChangePasswordKeys.operation.rawValue) else { return }
            guard let chainId: String = queue?.getValue(ChangePasswordKeys.chainId.rawValue) else { return }
            guard let blockData: BlockData = queue?.getValue(ChangePasswordKeys.blockData.rawValue) else { return }
            guard let fee: AssetAmount = queue?.getValue(ChangePasswordKeys.fee.rawValue) else { return }
            
            operation.fee = fee
            
            let transaction = Transaction(operations: [operation], blockData: blockData, chainId: chainId)
            
            guard let name = account.account.name else { return }
            guard let cryptoCore = self?.core else { return }
            guard let keyChain = ECHOKeychain(name: name, password: password, type: KeychainType.owner, core: cryptoCore) else { return }
            
            do {
                let generator = SignaturesGenerator()
                let signatures = try generator.signTransaction(transaction, privateKeys: [keyChain.raw], cryptoCore: cryptoCore)
                transaction.signatures = signatures
                queue?.saveValue(transaction, forKey: ChangePasswordKeys.transaciton.rawValue)
            } catch {
                queue?.cancelAllOperations()
                let result = Result<Bool, ECHOError>(error: ECHOError.undefined)
                completion(result)
            }
        }
        
        return bildTransferOperation
    }
    
    fileprivate func createSendUpdateOperation(_ queue: ECHOQueue,
                                               _ completion: @escaping Completion<Bool>) -> Operation {
        
        let sendTransactionOperation = BlockOperation()
        
        sendTransactionOperation.addExecutionBlock { [weak sendTransactionOperation, weak queue, weak self] in
            
            guard sendTransactionOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let transction: Transaction = queue?.getValue(ChangePasswordKeys.transaciton.rawValue) else { return }
            
            self?.services.networkBroadcastService.broadcastTransactionWithCallback(transaction: transction, completion: { (result) in
                switch result {
                case .success(let success):
                    let result = Result<Bool, ECHOError>(value: success)
                    completion(result)
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<Bool, ECHOError>(error: error)
                    completion(result)
                }
                
                queue?.startNextOperation()
            })
            
            queue?.waitStartNextOperation()
        }
        
        return sendTransactionOperation
    }
    
    fileprivate func checkAccount(account: UserAccount, name: String, password: String) -> Bool {
        
        guard let keychain = ECHOKeychain(name: name, password: password, type: .owner, core: core)  else {
            return false
        }
        
        let key = network.prefix.rawValue + keychain.publicAddress()
        let matches = account.account.owner?.keyAuths.compactMap { $0.address.addressString == key }.filter { $0 == true }
        
        if let matches = matches {
            return matches.count > 0
        }
        
        return false
    }
}
