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
    let cryptoCore: CryptoCoreComponent
    let network: Network
    
    init(services: AuthentificationFacadeServices, cryptoCore: CryptoCoreComponent, network: Network) {
        self.services = services
        self.cryptoCore = cryptoCore
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
    
    fileprivate func checkAccount(account: UserAccount, name: String, password: String) -> Bool {
        
        guard let keychain = ECHOKeychain(name: name, password: password, type: .owner, core: cryptoCore)  else {
            return false
        }
        
        let key = network.prefix.rawValue + keychain.publicAddress()
        let matches = account.account.owner?.keyAuths.compactMap { $0.address.addressString == key }.filter { $0 == true }
        
        if let matches = matches {
            return matches.count > 0
        }
        
        return false
    }

    
    fileprivate enum ChangePasswordKeys: String {
        case account
        case operation
        case fee
        case blockData
        case chainId
        case transaction
    }
    
    public func changePassword(old: String, new: String, name: String, completion: @escaping Completion<Bool>) {
        
        let changePasswordQueue = ECHOQueue()
        queues.append(changePasswordQueue)
        
        // Account
        let checkAccountOperation = createCheckAccountOperation(changePasswordQueue, name, old, completion)
        
        // Operation
        let accountUpdateOperation = createAccountUpdateOperation(changePasswordQueue, name, new, completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (changePasswordQueue,
                                                 services.databaseService,
                                                 Asset(Settings.defaultAsset),
                                                 ChangePasswordKeys.operation.rawValue,
                                                 ChangePasswordKeys.fee.rawValue)
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<Bool>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: completion)
        
        // ChainId
        let getChainIdInitParams = (changePasswordQueue, services.databaseService, ChangePasswordKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<Bool>(initParams: getChainIdInitParams,
                                                                 completion: completion)
        
        // BlockData
        let getBlockDataInitParams = (changePasswordQueue, services.databaseService, ChangePasswordKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<Bool>(initParams: getBlockDataInitParams,
                                                                     completion: completion)
        
        // Transaciton
        let transactionOperationInitParams = (queue: changePasswordQueue,
                                              cryptoCore: cryptoCore,
                                              keychainType: KeychainType.owner,
                                              saveKey: ChangePasswordKeys.transaction.rawValue,
                                              password: old,
                                              networkPrefix: network.prefix.rawValue,
                                              fromAccountKey: ChangePasswordKeys.account.rawValue,
                                              operationKey: ChangePasswordKeys.operation.rawValue,
                                              chainIdKey: ChangePasswordKeys.chainId.rawValue,
                                              blockDataKey: ChangePasswordKeys.blockData.rawValue,
                                              feeKey: ChangePasswordKeys.fee.rawValue)
        let bildTransactionOperation = GetTransactionQueueOperation<Bool>(initParams: transactionOperationInitParams,
                                                                          completion: completion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (changePasswordQueue,
                                                 services.networkBroadcastService,
                                                 ChangePasswordKeys.transaction.rawValue)
        let sendTransactionOperation = SendTransactionQueueOperation(initParams: sendTransacionOperationInitParams,
                                                                     completion: completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: changePasswordQueue)
        
        changePasswordQueue.addOperation(checkAccountOperation)
        changePasswordQueue.addOperation(accountUpdateOperation)
        changePasswordQueue.addOperation(getRequiredFeeOperation)
        changePasswordQueue.addOperation(getChainIdOperation)
        changePasswordQueue.addOperation(getBlockDataOperation)
        changePasswordQueue.addOperation(bildTransactionOperation)
        changePasswordQueue.addOperation(sendTransactionOperation)
        
        changePasswordQueue.setCompletionOperation(completionOperation)
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
                    queue?.saveValue(account.account, forKey: ChangePasswordKeys.account.rawValue)
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
            guard let cryptoCore = self?.cryptoCore else { return }
            guard let network = self?.network else { return }
            guard let account: Account = queue?.getValue(ChangePasswordKeys.account.rawValue) else { return }
            
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
            
            let operation = AccountUpdateOperation(account: account,
                                                   owner: ownerAuthority,
                                                   active: activeAuthority,
                                                   options: options,
                                                   fee: fee)
            
            queue?.saveValue(operation, forKey: ChangePasswordKeys.operation.rawValue)
        }
        
        return accountUpdateOperation
    }
}
