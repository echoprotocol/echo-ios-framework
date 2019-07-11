//
//  GetTransactionQueueOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 06.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

typealias GetTransactionQueueOperationInitParams = (queue: ECHOQueue,
                                                    cryptoCore: CryptoCoreComponent,
                                                    saveKey: String,
                                                    wif: String,
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
    fileprivate let saveKey: String
    fileprivate let wif: String
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
        self.saveKey = initParams.saveKey
        self.wif = initParams.wif
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
        guard let fee: FeeType = queue?.getValue(feeKey) else { return }
        guard let cryptoCore = cryptoCore else { return }
        
        guard let keyChain = ECHOKeychainEd25519(wif: wif, core: cryptoCore) else {
            queue?.cancelAllOperations()
            let result = Result<T, ECHOError>(error: ECHOError.invalidWIF)
            completion(result)
            return
        }
        
        if !checkAccount(account: account) {
            
            queue?.cancelAllOperations()
            let result = Result<T, ECHOError>(error: ECHOError.invalidCredentials)
            completion(result)
            return
        }
        
        switch fee {
        case .defaultFee(let assetAmount):
            operation.fee = assetAmount
        case .callContractFee(let callContractFee):
            operation.fee = callContractFee.fee
        }
        
        let transaction = Transaction(operations: [operation], blockData: blockData, chainId: chainId)
        
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
    
    fileprivate func checkAccount(account: Account) -> Bool {
        
        guard let cryptoCore = cryptoCore else { return false }
        
        guard let keychain = ECHOKeychainEd25519(wif: wif, core: cryptoCore) else {
            return false
        }
        
        let key = networkPrefix + keychain.publicAddress()
        
        let authority = account.active
        
        let matches = authority?.keyAuths.compactMap { $0.address.addressString == key }.filter { $0 == true }
        
        if let matches = matches {
            return matches.count > 0
        }
        
        return false
    }
}
