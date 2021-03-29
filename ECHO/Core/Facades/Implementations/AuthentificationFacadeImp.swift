//
//  AuthentificationFacadeImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct AuthentificationFacadeServices {
    let databaseService: DatabaseApiService
    let networkBroadcastService: NetworkBroadcastApiService
}

/**
    Implementation of [AuthentificationFacade](AuthentificationFacade), [ECHOQueueble](ECHOQueueble)
 */
final public class AuthentificationFacadeImp: AuthentificationFacade, ECHOQueueble, NoticeEventDelegate {
    public var queues: [String: ECHOQueue]
    let services: AuthentificationFacadeServices
    let cryptoCore: CryptoCoreComponent
    let network: ECHONetwork
    let transactionExpirationOffset: TimeInterval
    
    init(services: AuthentificationFacadeServices,
         cryptoCore: CryptoCoreComponent,
         network: ECHONetwork,
         noticeDelegateHandler: NoticeEventDelegateHandler,
         transactionExpirationOffset: TimeInterval) {
        self.services = services
        self.cryptoCore = cryptoCore
        self.network = network
        self.transactionExpirationOffset = transactionExpirationOffset
        self.queues = [String: ECHOQueue]()
        noticeDelegateHandler.delegate = self
    }
    
    public func generateRandomWIF() -> String {
        
        let keychain = ECHOKeychainEd25519(core: cryptoCore)
        return keychain.wif()
    }
    
    public func isOwnedBy(name: String, wif: String, completion: @escaping Completion<UserAccount>) {
        
        services.databaseService.getFullAccount(nameOrIds: [name], shoudSubscribe: false) { [weak self] (result) in
            switch result {
            case .success(let userAccounts):
                
                guard let strongSelf = self else {
                    return
                }
                
                guard let account = userAccounts[name] else {
                    let result = Result<UserAccount, ECHOError>(error: ECHOError.resultNotFound)
                    completion(result)
                    return
                }
                
                guard let keychain = ECHOKeychainEd25519(wif: wif, core: strongSelf.cryptoCore) else {
                    let result = Result<UserAccount, ECHOError>(error: ECHOError.invalidWIF)
                    completion(result)
                    return
                }
                
                if self?.checkAccount(account: account, keychain: keychain) == true {
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
    
    public func isOwnedBy(wif: String, completion: @escaping Completion<[UserAccount]>) {
        
        guard let keychain = ECHOKeychainEd25519(wif: wif, core: cryptoCore) else {
            let result = Result<[UserAccount], ECHOError>(error: ECHOError.invalidWIF)
            completion(result)
            return
        }
        
        let publicAdderess = network.echorandPrefix.rawValue + keychain.publicAddress()
        
        services.databaseService.getKeyReferences(keys: [publicAdderess]) { [weak self] (result) in
            
            switch result {
            case .success(let arrayOfUserIds):
                
                guard let userIds = arrayOfUserIds.first else {
                    let result = Result<[UserAccount], ECHOError>(value: [])
                    completion(result)
                    return
                }
                
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.services.databaseService.getFullAccount(nameOrIds: userIds,
                                                                   shoudSubscribe: false,
                                                                   completion: { (result) in
                    
                    switch result {
                    case .success(let userAccounts):
                        let array = Array(userAccounts.values)
                        let result = Result<[UserAccount], ECHOError>(value: array)
                        completion(result)
                    case .failure(let error):
                        let result = Result<[UserAccount], ECHOError>(error: error)
                        completion(result)
                    }
                })
            case .failure(let error):
                let result = Result<[UserAccount], ECHOError>(error: error)
                completion(result)
            }
        }
    }
    
    fileprivate func checkAccount(account: UserAccount, keychain: ECHOKeychainEd25519) -> Bool {
        
        let key = network.echorandPrefix.rawValue + keychain.publicAddress()
        let matches = account.account.active?.keyAuths.compactMap { $0.address.addressString == key }.filter { $0 == true }
        
        if let matches = matches {
            return matches.count > 0
        }
        
        return false
    }

    fileprivate enum ChangeKeysKeys: String {
        case account
        case operation
        case fee
        case blockData
        case chainId
        case transaction
    }
    
    public func changeKeys(
        oldWIF: String,
        newWIF: String,
        name: String,
        sendCompletion: @escaping Completion<String>,
        confirmNoticeHandler: NoticeHandler?
    ) {
        
        let changeKeysQueue = ECHOQueue()
        addQueue(changeKeysQueue)
        
        // Account
        let checkAccountOperation = createCheckAccountOperation(changeKeysQueue, name, oldWIF, sendCompletion)
        
        // Operation
        let accountUpdateOperation = createAccountUpdateOperation(changeKeysQueue, name, newWIF, sendCompletion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (changeKeysQueue,
                                                 services.databaseService,
                                                 Asset(Settings.defaultAsset),
                                                 ChangeKeysKeys.operation.rawValue,
                                                 ChangeKeysKeys.fee.rawValue,
                                                 UInt(1))
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<String>(initParams: getRequiredFeeOperationInitParams,
                                                                           completion: sendCompletion)
        
        // ChainId
        let getChainIdInitParams = (changeKeysQueue, services.databaseService, ChangeKeysKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<String>(initParams: getChainIdInitParams,
                                                                   completion: sendCompletion)
        
        // BlockData
        let getBlockDataInitParams = (changeKeysQueue, services.databaseService, ChangeKeysKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<String>(initParams: getBlockDataInitParams,
                                                                       completion: sendCompletion)
        
        // Transaciton
        let transactionOperationInitParams = (queue: changeKeysQueue,
                                              cryptoCore: cryptoCore,
                                              saveKey: ChangeKeysKeys.transaction.rawValue,
                                              wif: oldWIF,
                                              networkPrefix: network.echorandPrefix.rawValue,
                                              fromAccountKey: ChangeKeysKeys.account.rawValue,
                                              operationKey: ChangeKeysKeys.operation.rawValue,
                                              chainIdKey: ChangeKeysKeys.chainId.rawValue,
                                              blockDataKey: ChangeKeysKeys.blockData.rawValue,
                                              feeKey: ChangeKeysKeys.fee.rawValue,
                                              expirationOffset: transactionExpirationOffset)
        let bildTransactionOperation = GetTransactionQueueOperation<String>(initParams: transactionOperationInitParams,
                                                                            completion: sendCompletion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (changeKeysQueue,
                                                 services.networkBroadcastService,
                                                 EchoQueueMainKeys.operationId.rawValue,
                                                 ChangeKeysKeys.transaction.rawValue)
        let sendTransactionOperation = SendTransactionQueueOperation(initParams: sendTransacionOperationInitParams,
                                                                     completion: sendCompletion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: changeKeysQueue)
        
        changeKeysQueue.addOperation(checkAccountOperation)
        changeKeysQueue.addOperation(accountUpdateOperation)
        changeKeysQueue.addOperation(getRequiredFeeOperation)
        changeKeysQueue.addOperation(getChainIdOperation)
        changeKeysQueue.addOperation(getBlockDataOperation)
        changeKeysQueue.addOperation(bildTransactionOperation)
        changeKeysQueue.addOperation(sendTransactionOperation)
        
        //Notice handler
        if let noticeHandler = confirmNoticeHandler {
            changeKeysQueue.saveValue(noticeHandler, forKey: EchoQueueMainKeys.noticeHandler.rawValue)
            
            let waitingOperationParams = (
                changeKeysQueue,
                EchoQueueMainKeys.notice.rawValue,
                EchoQueueMainKeys.noticeError.rawValue
            )
            let waitOperation = WaitQueueOperation(initParams: waitingOperationParams)
            
            let noticeHadleOperaitonParams = (
                changeKeysQueue,
                EchoQueueMainKeys.notice.rawValue,
                EchoQueueMainKeys.noticeError.rawValue,
                EchoQueueMainKeys.noticeHandler.rawValue
            )
            let noticeHandleOperation = NoticeHandleQueueOperation(initParams: noticeHadleOperaitonParams)
            
            changeKeysQueue.addOperation(waitOperation)
            changeKeysQueue.addOperation(noticeHandleOperation)
        }
        
        changeKeysQueue.addOperation(completionOperation)
    }
    
    fileprivate func createCheckAccountOperation(_ queue: ECHOQueue,
                                                 _ name: String,
                                                 _ wif: String,
                                                 _ completion: @escaping Completion<String>) -> Operation {
        
        let checkAccountOperation = BlockOperation()
        
        checkAccountOperation.addExecutionBlock { [weak checkAccountOperation, weak self, weak queue] in
            
            guard checkAccountOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            
            self?.isOwnedBy(name: name, wif: wif, completion: { (result) in
                switch result {
                case .success(let account):
                    queue?.saveValue(account.account, forKey: ChangeKeysKeys.account.rawValue)
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<String, ECHOError>(error: error)
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
                                                  _ wif: String,
                                                  _ completion: @escaping Completion<String>) -> Operation {
        
        let accountUpdateOperation = BlockOperation()
        
        accountUpdateOperation.addExecutionBlock { [weak accountUpdateOperation, weak self, weak queue] in
            
            guard accountUpdateOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let cryptoCore = self?.cryptoCore else { return }
            guard let network = self?.network else { return }
            guard let account: Account = queue?.getValue(ChangeKeysKeys.account.rawValue) else { return }
            
            guard let keychain = ECHOKeychainEd25519(wif: wif, core: cryptoCore) else {
                queue?.cancelAllOperations()
                let result = Result<String, ECHOError>(error: ECHOError.invalidWIF)
                completion(result)
                return
            }
            
            let addressString = network.echorandPrefix.rawValue + keychain.publicAddress()
            let address = Address(addressString, data: keychain.publicKey())
            
            let activeKeyAddressAuth = AddressAuthority(address: address, value: 1)
            let activeAuthority = Authority(weight: 1, keyAuth: [activeKeyAddressAuth], accountAuth: [])
            
            var delegatingAccount: Account?
            if let delegatingAccountId = account.options?.delegatingAccount {
                delegatingAccount = Account(delegatingAccountId)
            }
            
            let options = AccountOptions(delegatingAccount: delegatingAccount)
            
            let fee = AssetAmount(amount: 0, asset: Asset(Settings.defaultAsset))
            
            let operation = AccountUpdateOperation(account: account,
                                                   active: activeAuthority,
                                                   edKey: address,
                                                   options: options,
                                                   fee: fee)
            
            queue?.saveValue(operation, forKey: ChangeKeysKeys.operation.rawValue)
        }
        
        return accountUpdateOperation
    }
}
