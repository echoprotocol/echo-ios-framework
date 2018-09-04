//
//  TransactionFacadeImp.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 28.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Services for TransactionFacade
 */
public struct TransactionFacadeServices {
    var databaseService: DatabaseApiService
    var networkBroadcastService: NetworkBroadcastApiService
}

/**
    Implementation of [TransactionFacade](TransactionFacade)
 */
final public class TransactionFacadeImp: TransactionFacade, ECHOQueueble {
    
    var queues: [ECHOQueue]
    let services: TransactionFacadeServices
    let network: Network
    let cryptoCore: CryptoCoreComponent
    
    public init(services: TransactionFacadeServices, cryptoCore: CryptoCoreComponent, network: Network) {
        
        self.services = services
        self.network = network
        self.cryptoCore = cryptoCore
        self.queues = [ECHOQueue]()
    }
    
    private enum TransferResultsKeys: String {
        case loadedToAccount
        case loadedFromAccount
        case blockData
        case chainId
        case operation
        case fee
        case transaciton
    }
    
    public func sendTransferOperation(fromNameOrId: String,
                                      password: String,
                                      toNameOrId: String,
                                      amount: UInt,
                                      asset: String,
                                      message: String?,
                                      completion: @escaping Completion<Bool>) {
        
        let transferQueue = ECHOQueue()
        queues.append(transferQueue)
        
        let getAccountsOperation = createGetAccountsOperation(transferQueue, fromNameOrId, toNameOrId, completion)
        let bildTransferOperation = createBildTransferOperation(transferQueue, password, message, amount, asset, completion)
        let getRequiredFee = createGetRequiredFeeOperation(transferQueue, asset, completion)
        let getChainIdOperation = createChainIdOperation(transferQueue, completion)
        let getBlockDataOperation = createGetBlockDataOperation(transferQueue, completion)
        let bildTransacitonOperation = createBildTransactionOperation(transferQueue, password, completion)
        let sendTransacitonOperation = createSendTransactionOperation(transferQueue, completion)
        let lastOperation = createLastOperation(queue: transferQueue)
        
        transferQueue.addOperation(getAccountsOperation)
        transferQueue.addOperation(bildTransferOperation)
        transferQueue.addOperation(getRequiredFee)
        transferQueue.addOperation(getChainIdOperation)
        transferQueue.addOperation(getBlockDataOperation)
        transferQueue.addOperation(bildTransacitonOperation)
        transferQueue.addOperation(sendTransacitonOperation)
        transferQueue.addOperation(lastOperation)
    }
    
    fileprivate func createGetAccountsOperation(_ queue: ECHOQueue,
                                                _ fromNameOrId: String,
                                                _ toNameOrId: String,
                                                _ completion: @escaping Completion<Bool>) -> Operation {
        
        let getAccountsOperation = BlockOperation()
        
        getAccountsOperation.addExecutionBlock { [weak getAccountsOperation, weak queue, weak self] in
            
            guard getAccountsOperation?.isCancelled == false else { return }
            
            self?.services.databaseService.getFullAccount(nameOrIds: [fromNameOrId, toNameOrId], shoudSubscribe: false, completion: { (result) in
                switch result {
                case .success(let accounts):
                    if let fromAccount = accounts[fromNameOrId], let toAccount = accounts[toNameOrId] {
                        queue?.saveValue(fromAccount.account, forKey: TransferResultsKeys.loadedFromAccount.rawValue)
                        queue?.saveValue(toAccount.account, forKey: TransferResultsKeys.loadedToAccount.rawValue)
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
        
        return getAccountsOperation
    }
    
    fileprivate func createGetBlockDataOperation(_ queue: ECHOQueue,
                                                 _ completion: @escaping Completion<Bool>) -> Operation {
        
        let getBlockDataOperation = BlockOperation()
        
        getBlockDataOperation.addExecutionBlock { [weak getBlockDataOperation, weak queue, weak self] in
            
            guard getBlockDataOperation?.isCancelled == false else { return }
            
            self?.services.databaseService.getBlockData(completion: { (result) in
                switch result {
                case .success(let blockData):
                    queue?.saveValue(blockData, forKey: TransferResultsKeys.blockData.rawValue)
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
            
            self?.services.databaseService.getChainId(completion: { (result) in
                switch result {
                case .success(let chainId):
                    queue?.saveValue(chainId, forKey: TransferResultsKeys.chainId.rawValue)
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
    
    fileprivate func createBildTransferOperation(_ queue: ECHOQueue,
                                                 _ password: String,
                                                 _ message: String?,
                                                 _ amount: UInt,
                                                 _ asset: String,
                                                 _ completion: @escaping Completion<Bool>) -> Operation {
        
        let bildTransferOperation = BlockOperation()
        
        bildTransferOperation.addExecutionBlock { [weak bildTransferOperation, weak queue, weak self] in
            
            guard bildTransferOperation?.isCancelled == false else { return }
            
            guard let fromAccount: Account = queue?.getValue(TransferResultsKeys.loadedFromAccount.rawValue) else { return }
            guard let toAccount: Account = queue?.getValue(TransferResultsKeys.loadedToAccount.rawValue) else { return }
            
            if let strongSelf = self,
                    !strongSelf.checkAccount(account: fromAccount, name: fromAccount.name, password: password) {
                
                queue?.cancelAllOperations()
                let result = Result<Bool, ECHOError>(error: ECHOError.invalidCredentials)
                completion(result)
                return
            }
            
            guard let cryptoCore = self?.cryptoCore,
                let name = fromAccount.name,
                let keyChain = ECHOKeychain(name: name, password: password, type: KeychainType.memo, core: cryptoCore) else {
                    
                    queue?.cancelAllOperations()
                    let result = Result<Bool, ECHOError>(error: ECHOError.invalidCredentials)
                    completion(result)
                    return
            }
            
            let memo = self?.createMemo(privateKey: keyChain.raw, fromAccount: fromAccount, toAccount: toAccount, message: message)
            
            let fee = AssetAmount(amount: 0, asset: Asset(asset))
            let amount = AssetAmount(amount: amount, asset: Asset(asset))
            let extractedExpr: TransferOperation = TransferOperation(from: fromAccount,
                                                                     to: toAccount,
                                                                     transferAmount: amount,
                                                                     fee: fee,
                                                                     memo: memo)
            let transferOperation = extractedExpr
            
            queue?.saveValue(transferOperation, forKey: TransferResultsKeys.operation.rawValue)
        }
        
        return bildTransferOperation
    }

    fileprivate func createMemo(privateKey: Data,
                                fromAccount: Account,
                                toAccount: Account,
                                message: String?) -> Memo {
        
        guard let message = message else {
            return Memo()
        }
        
        guard let fromMemoKeyString = fromAccount.options?.memoKey else {
            return Memo()
        }

        guard let toMemoKeyString = toAccount.options?.memoKey else {
            return Memo()
        }
        
        let fromPublicKey = cryptoCore.getPublicKeyFromAddress(fromMemoKeyString, networkPrefix: network.prefix.rawValue)
        let toPublicKey = cryptoCore.getPublicKeyFromAddress(toMemoKeyString, networkPrefix: network.prefix.rawValue)
        
        let nonce = 0
        let byteMessage = cryptoCore.encryptMessage(privateKey: privateKey,
                                                    publicKey: toPublicKey,
                                                    nonce: String(format: "%llu", nonce), message: message)
        
        let memo = Memo(source: Address(fromAccount.options!.memoKey, data: fromPublicKey),
                        destination: Address(toAccount.options!.memoKey, data: toPublicKey),
                        nonce: nonce,
                        byteMessage: byteMessage)
        
        return memo
    }

    fileprivate func checkAccount(account: Account, name: String?, password: String) -> Bool {

        guard let name = name else {
            return false
        }
        
        guard let keychain = ECHOKeychain(name: name, password: password, type: .owner, core: cryptoCore)  else {
            return false
        }
        
        let key = network.prefix.rawValue + keychain.publicAddress()
        let matches = account.owner?.keyAuths.compactMap { $0.address.addressString == key }.filter { $0 == true }
        
        if let matches = matches {
            return matches.count > 0
        }
        
        return false
    }
    
    fileprivate func createGetRequiredFeeOperation(_ queue: ECHOQueue,
                                                   _ asset: String,
                                                   _ completion: @escaping Completion<Bool>) -> Operation {
        
        let getRequiredFee = BlockOperation()
        
        getRequiredFee.addExecutionBlock { [weak getRequiredFee, weak queue, weak self] in
            
            guard getRequiredFee?.isCancelled == false else { return }
            guard let operation: TransferOperation = queue?.getValue(TransferResultsKeys.operation.rawValue) else { return }
            
            let asset = Asset(asset)
            
            self?.services.databaseService.getRequiredFees(operations: [operation], asset: asset, completion: { (result) in
                switch result {
                case .success(let fees):
                    if let fee = fees.first {
                        queue?.saveValue(fee, forKey: TransferResultsKeys.fee.rawValue)
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
    
    fileprivate func createBildTransactionOperation(_ queue: ECHOQueue,
                                                    _ password: String,
                                                    _ completion: @escaping Completion<Bool>) -> Operation {
        
        let bildTransferOperation = BlockOperation()
        
        bildTransferOperation.addExecutionBlock { [weak bildTransferOperation, weak queue, weak self] in
            
            guard bildTransferOperation?.isCancelled == false else { return }
            
            guard var operation: TransferOperation = queue?.getValue(TransferResultsKeys.operation.rawValue) else { return }
            guard let chainId: String = queue?.getValue(TransferResultsKeys.chainId.rawValue) else { return }
            guard let blockData: BlockData = queue?.getValue(TransferResultsKeys.blockData.rawValue) else { return }
            guard let fee: AssetAmount = queue?.getValue(TransferResultsKeys.fee.rawValue) else { return }
            
            operation.fee = fee
            
            let transaction = Transaction(operations: [operation], blockData: blockData, chainId: chainId)
            
            guard let name = operation.from.name else { return }
            guard let cryptoCore = self?.cryptoCore else { return }
            guard let keyChain = ECHOKeychain(name: name, password: password, type: KeychainType.active, core: cryptoCore) else { return }
            
            do {
                let generator = SignaturesGenerator()
                let signatures = try generator.signTransaction(transaction, privateKeys: [keyChain.raw], cryptoCore: cryptoCore)
                transaction.signatures = signatures
                queue?.saveValue(transaction, forKey: TransferResultsKeys.transaciton.rawValue)
            } catch {
                queue?.cancelAllOperations()
                let result = Result<Bool, ECHOError>(error: ECHOError.undefined)
                completion(result)
            }
        }
        
        return bildTransferOperation
    }
    
    fileprivate func createSendTransactionOperation(_ queue: ECHOQueue,
                                                    _ completion: @escaping Completion<Bool>) -> Operation {
    
        let sendTransactionOperation = BlockOperation()
        
        sendTransactionOperation.addExecutionBlock { [weak sendTransactionOperation, weak queue, weak self] in
            
            guard sendTransactionOperation?.isCancelled == false else { return }
            guard let transction: Transaction = queue?.getValue(TransferResultsKeys.transaciton.rawValue) else { return }
            
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
}
