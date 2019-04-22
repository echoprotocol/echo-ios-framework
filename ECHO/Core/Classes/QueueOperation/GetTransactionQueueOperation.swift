//
//  GetTransactionQueueOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 06.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

typealias GetTransactionQueueOperationInitParams = (queue: ECHOQueue,
                                                    cryptoCore: CryptoCoreComponent,
                                                    keychainType: KeychainType,
                                                    saveKey: String,
                                                    passwordOrWif: PassOrWif,
                                                    networkPrefix: String,
                                                    fromAccountKey: String,
                                                    operationKey: String,
                                                    chainIdKey: String,
                                                    blockDataKey: String,
                                                    feeKey: String)

/**
    Operation for [ECHOQueue](ECHOQueue) whitch create, sign and save transaction
 
    - Save [Transaction](Transaction)
 */
final class GetTransactionQueueOperation<T>: Operation where T: Any {
    
    fileprivate weak var queue: ECHOQueue?
    fileprivate weak var cryptoCore: CryptoCoreComponent?
    fileprivate let keychainType: KeychainType
    fileprivate let saveKey: String
    fileprivate let passwordOrWif: PassOrWif
    fileprivate let networkPrefix: String
    fileprivate let fromAccountKey: String
    fileprivate let operationKey: String
    fileprivate let chainIdKey: String
    fileprivate let blockDataKey: String
    fileprivate let feeKey: String
    fileprivate let completion: Completion<T>
    
    required init(initParams: GetTransactionQueueOperationInitParams, completion: @escaping Completion<T>) {
        
        self.queue = initParams.queue
        self.cryptoCore = initParams.cryptoCore
        self.keychainType = initParams.keychainType
        self.saveKey = initParams.saveKey
        self.passwordOrWif = initParams.passwordOrWif
        self.networkPrefix = initParams.networkPrefix
        self.fromAccountKey = initParams.fromAccountKey
        self.operationKey = initParams.operationKey
        self.chainIdKey = initParams.chainIdKey
        self.blockDataKey = initParams.blockDataKey
        self.feeKey = initParams.feeKey
        self.completion = completion
    }
    
    override func main() {
        super.main()
        
        if isCancelled { return }
        
        guard let account: Account = queue?.getValue(fromAccountKey) else { return }
        guard var operation: BaseOperation = queue?.getValue(operationKey) else { return }
        guard let chainId: String = queue?.getValue(chainIdKey) else { return }
        guard let blockData: BlockData = queue?.getValue(blockDataKey) else { return }
        guard let fee: AssetAmount = queue?.getValue(feeKey) else { return }
        
        if !checkAccount(account: account, name: account.name) {
            
            queue?.cancelAllOperations()
            let result = Result<T, ECHOError>(error: ECHOError.invalidCredentials)
            completion(result)
            return
        }
        
        operation.fee = fee
        
        let transaction = Transaction(operations: [operation], blockData: blockData, chainId: chainId)
        
        guard let name = account.name else { return }
        guard let cryptoCore = cryptoCore else { return }
        
        var keysContrainer: AddressKeysContainer?
        switch passwordOrWif {
        case .password(let pass):
            keysContrainer = AddressKeysContainer(login: name,
                                                  password: pass,
                                                  core: cryptoCore)
        case .wif(let wif):
            keysContrainer = AddressKeysContainer(wif: wif,
                                                  core: cryptoCore)
        }
        
        guard let contrainer = keysContrainer else {
            return
        }
        
        var keyChain = contrainer.activeKeychain
        switch keychainType {
        case .active:
            keyChain = contrainer.activeKeychain
        case .memo:
            keyChain = contrainer.memoKeychain
        case .owner:
            keyChain = contrainer.ownerKeychain
        case .echorand:
            keyChain = contrainer.echorandKeychain
        }
        
        do {
            let generator = SignaturesGenerator()
            let signatures = try generator.signTransaction(transaction, privateKeys: [keyChain.raw], cryptoCore: cryptoCore)
            transaction.signatures = signatures
            queue?.saveValue(transaction, forKey: saveKey)
        } catch {
            queue?.cancelAllOperations()
            let result = Result<T, ECHOError>(error: ECHOError.undefined)
            completion(result)
        }
    }
    
    fileprivate func checkAccount(account: Account, name: String?) -> Bool {
        
        guard let name = name else { return false }
        guard let cryptoCore = cryptoCore else { return false }
        
        var keysContrainer: AddressKeysContainer?
        switch passwordOrWif {
        case .password(let pass):
            keysContrainer = AddressKeysContainer(login: name,
                                                  password: pass,
                                                  core: cryptoCore)
        case .wif(let wif):
            keysContrainer = AddressKeysContainer(wif: wif,
                                                  core: cryptoCore)
        }
        
        guard let contrainer = keysContrainer else {
            return false
        }
        
        let key = networkPrefix + contrainer.ownerKeychain.publicAddress()
        
        let authority: Authority?
        switch keychainType {
        case .active:
            authority = account.active
        default:
            authority = nil
        }
        
        let matches = authority?.keyAuths.compactMap { $0.address.addressString == key }.filter { $0 == true }
        
        if let matches = matches {
            return matches.count > 0
        }
        
        return false
    }
}
