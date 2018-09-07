//
//  GetTransactionQueueOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 06.09.2018.
//

typealias GetTransactionQueueOperationInitParams = (queue: ECHOQueue,
                                                    cryptoCore: CryptoCoreComponent,
                                                    keychainType: KeychainType,
                                                    saveKey: String,
                                                    password: String,
                                                    networkPrefix: String,
                                                    fromAccountKey: String,
                                                    operationKey: String,
                                                    chainIdKey: String,
                                                    blockDataKey: String,
                                                    feeKey: String)

final class GetTransactionQueueOperation<T>: Operation where T: Any {
    
    fileprivate weak var queue: ECHOQueue?
    fileprivate weak var cryptoCore: CryptoCoreComponent?
    fileprivate let keychainType: KeychainType
    fileprivate let saveKey: String
    fileprivate let password: String
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
        self.password = initParams.password
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
        
        if !checkAccount(account: account, name: account.name, password: password) {
            
            queue?.cancelAllOperations()
            let result = Result<T, ECHOError>(error: ECHOError.invalidCredentials)
            completion(result)
            return
        }
        
        operation.fee = fee
        
        let transaction = Transaction(operations: [operation], blockData: blockData, chainId: chainId)
        
        guard let name = account.name else { return }
        guard let cryptoCore = cryptoCore else { return }
        
        guard let keyChain = ECHOKeychain(name: name,
                                          password: password,
                                          type: keychainType,
                                          core: cryptoCore) else { return }
        
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
    
    fileprivate func checkAccount(account: Account, name: String?, password: String) -> Bool {
        
        guard let name = name else { return false }
        guard let cryptoCore = cryptoCore else { return false }
        
        guard let keychain = ECHOKeychain(name: name, password: password, type: .owner, core: cryptoCore)  else {
            return false
        }
        
        let key = networkPrefix + keychain.publicAddress()
        let matches = account.owner?.keyAuths.compactMap { $0.address.addressString == key }.filter { $0 == true }
        
        if let matches = matches {
            return matches.count > 0
        }
        
        return false
    }
}
