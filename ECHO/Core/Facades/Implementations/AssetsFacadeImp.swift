//
//  AssetsFacadeImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 04.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public struct AssetsServices {
    var databaseService: DatabaseApiService
    var networkBroadcastService: NetworkBroadcastApiService
}

final public class AssetsFacadeImp: AssetsFacade, ECHOQueueble {
    
    var queues: [ECHOQueue]
    let services: AssetsServices
    let cryptoCore: CryptoCoreComponent
    let network: Network
    
    private enum CreateAssetKeys: String {
        case account
        case operation
        case fee
        case blockData
        case chainId
        case transaction
    }
    
    private enum IssueAssetKeys: String {
        case issuerAccount
        case destinationAccount
        case operation
        case fee
        case blockData
        case chainId
        case transaction
    }
    
    public init(services: AssetsServices, cryptoCore: CryptoCoreComponent, network: Network) {
        
        self.services = services
        self.cryptoCore = cryptoCore
        self.network = network
        self.queues = [ECHOQueue]()
    }
    
    public func createAsset(nameOrId: String, password: String, asset: Asset, completion: @escaping Completion<Bool>) {
        
        let createAssetQueue = ECHOQueue()
        queues.append(createAssetQueue)
        
        let getAccountOperation = createGetAccountsOperation(createAssetQueue, [(nameOrId, CreateAssetKeys.account.rawValue)], completion)
        let createAssetOperation = self.createAssetOperation(createAssetQueue, asset, completion)
        let getRequiredFeeOperation = createGetRequiredFeeOperation(createAssetQueue,
                                                                    CreateAssetKeys.operation.rawValue,
                                                                    CreateAssetKeys.fee.rawValue,
                                                                    completion)
        let getChainIdOperation = createChainIdOperation(createAssetQueue, CreateAssetKeys.chainId.rawValue, completion)
        let getBlockDataOperation = createGetBlockDataOperation(createAssetQueue, CreateAssetKeys.blockData.rawValue, completion)
        let bildTransactionOperation = createBildTransactionOperation(createAssetQueue, password, completion)
        let sendTransactionOperation = createSendTransactionOperation(createAssetQueue, CreateAssetKeys.transaction.rawValue, completion)
        let lastOperation = createLastOperation(queue: createAssetQueue)
        
        createAssetQueue.addOperation(getAccountOperation)
        createAssetQueue.addOperation(createAssetOperation)
        createAssetQueue.addOperation(getRequiredFeeOperation)
        createAssetQueue.addOperation(getChainIdOperation)
        createAssetQueue.addOperation(getBlockDataOperation)
        createAssetQueue.addOperation(bildTransactionOperation)
        createAssetQueue.addOperation(sendTransactionOperation)
        createAssetQueue.addOperation(lastOperation)
    }
    
    public func issueAsset(issuerNameOrId: String, password: String,
                           asset: String, amount: UInt,
                           destinationIdOrName: String, message: String?,
                           completion: @escaping Completion<Bool>) {
        
        let issueAssetQueue = ECHOQueue()
        queues.append(issueAssetQueue)
        
        let getAccountsOperaton = createGetAccountsOperation(issueAssetQueue,
                                                             [(issuerNameOrId, IssueAssetKeys.issuerAccount.rawValue),
                                                              (destinationIdOrName, IssueAssetKeys.destinationAccount.rawValue)],
                                                             completion)
        let createIssueAssetOperation = self.createIssueAssetOperation(issueAssetQueue, password, amount, asset, message, completion)
        let getRequiredFeeOperation = createGetRequiredFeeOperation(issueAssetQueue,
                                                                    IssueAssetKeys.operation.rawValue,
                                                                    IssueAssetKeys.fee.rawValue,
                                                                    completion)
        let getChainIdOperation = createChainIdOperation(issueAssetQueue, IssueAssetKeys.chainId.rawValue, completion)
        let getBlockDataOperation = createGetBlockDataOperation(issueAssetQueue, IssueAssetKeys.blockData.rawValue, completion)
        let bildTransactionOperation = issueBildTransactionOperation(issueAssetQueue, password, completion)
        let sendTransactionOperation = createSendTransactionOperation(issueAssetQueue, IssueAssetKeys.transaction.rawValue, completion)
        let lastOperation = createLastOperation(queue: issueAssetQueue)
        
        issueAssetQueue.addOperation(getAccountsOperaton)
        issueAssetQueue.addOperation(createIssueAssetOperation)
        issueAssetQueue.addOperation(getRequiredFeeOperation)
        issueAssetQueue.addOperation(getChainIdOperation)
        issueAssetQueue.addOperation(getBlockDataOperation)
        issueAssetQueue.addOperation(bildTransactionOperation)
        issueAssetQueue.addOperation(sendTransactionOperation)
        issueAssetQueue.addOperation(lastOperation)
    }
    
    public func listAssets(lowerBound: String, limit: Int, completion: @escaping Completion<[Asset]>) {
        services.databaseService.listAssets(lowerBound: lowerBound, limit: limit, completion: completion)
    }
    
    public func getAsset(assetIds: [String], completion: @escaping Completion<[Asset]>) {
        services.databaseService.getAssets(assetIds: assetIds, completion: completion)
    }
    
    fileprivate func createGetAccountsOperation(_ queue: ECHOQueue,
                                                _ namesOrIdsWithKeys: [(nameOrId: String, keyForSave: String)],
                                                _ completion: @escaping Completion<Bool>) -> Operation {
        
        let getAccountsOperation = BlockOperation()
        
        getAccountsOperation.addExecutionBlock { [weak getAccountsOperation, weak queue, weak self] in
            
            guard getAccountsOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            
            var namesOrIds = [String]()
            namesOrIdsWithKeys.forEach{
                namesOrIds.append($0.nameOrId)
            }
            
            self?.services.databaseService.getFullAccount(nameOrIds: namesOrIds, shoudSubscribe: false, completion: { (result) in
                switch result {
                case .success(let accounts):
                    
                    var wasNotFound = false
                    namesOrIdsWithKeys.forEach{
                        guard let account = accounts[$0.nameOrId] else {
                            wasNotFound = true
                            return
                        }
                        queue?.saveValue(account.account, forKey: $0.keyForSave)
                    }
                    
                    if wasNotFound {
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
    
    fileprivate func createIssueAssetOperation(_ queue: ECHOQueue,
                                               _ password: String,
                                               _ amount: UInt,
                                               _ asset: String,
                                               _ message: String?,
                                               _ completion: @escaping Completion<Bool>) -> Operation {
        
        let createIssueAssetOperation = BlockOperation()
        
        createIssueAssetOperation.addExecutionBlock { [weak createIssueAssetOperation, weak self, weak queue] in
            
            guard createIssueAssetOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let issuerAccount: Account = queue?.getValue(IssueAssetKeys.issuerAccount.rawValue) else { return }
            guard let destinationAccount: Account = queue?.getValue(IssueAssetKeys.destinationAccount.rawValue) else { return }
            
            if let strongSelf = self,
                !strongSelf.checkAccount(account: issuerAccount, name: issuerAccount.name, password: password) {
                
                queue?.cancelAllOperations()
                let result = Result<Bool, ECHOError>(error: ECHOError.invalidCredentials)
                completion(result)
                return
            }
            
            guard let cryptoCore = self?.cryptoCore,
                let name = issuerAccount.name,
                let keyChain = ECHOKeychain(name: name, password: password, type: KeychainType.memo, core: cryptoCore) else {
                    
                    queue?.cancelAllOperations()
                    let result = Result<Bool, ECHOError>(error: ECHOError.invalidCredentials)
                    completion(result)
                    return
            }
            
            let memo = self?.createMemo(privateKey: keyChain.raw, fromAccount: issuerAccount, toAccount: destinationAccount, message: message)
            let fee = AssetAmount(amount: 0, asset: Asset(Settings.defaultAsset))
            let assetToIssue = AssetAmount(amount: amount, asset: Asset(asset))
            
            let operation = IssueAssetOperation(issuer: issuerAccount,
                                                assetToIssue: assetToIssue,
                                                issueToAccount: destinationAccount,
                                                fee: fee,
                                                memo: memo)
            
            queue?.saveValue(operation, forKey: IssueAssetKeys.operation.rawValue)
        }
        
        return createIssueAssetOperation
    }
    
    fileprivate func createAssetOperation(_ queue: ECHOQueue,
                                          _ asset: Asset,
                                          _ completion: @escaping Completion<Bool>) -> Operation {
        
        let createAssetOperation = BlockOperation()
        
        createAssetOperation.addExecutionBlock { [weak createAssetOperation, weak self, weak queue] in
            
            guard createAssetOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            
            let fee = AssetAmount(amount: 0, asset: Asset(Settings.defaultAsset))
            let operation = CreateAssetOperation(asset: asset, fee: fee)
            
            queue?.saveValue(operation, forKey: CreateAssetKeys.operation.rawValue)
        }
        
        return createAssetOperation
    }
    
    fileprivate func createGetRequiredFeeOperation(_ queue: ECHOQueue,
                                                   _ getOperationKey: String,
                                                   _ saveFeeKey: String,
                                                   _ completion: @escaping Completion<Bool>) -> Operation {
        
        let getRequiredFee = BlockOperation()
        
        getRequiredFee.addExecutionBlock { [weak getRequiredFee, weak queue, weak self] in
            
            guard getRequiredFee?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let operation: BaseOperation = queue?.getValue(getOperationKey) else { return }
            
            let asset = Asset(Settings.defaultAsset)
            
            self?.services.databaseService.getRequiredFees(operations: [operation], asset: asset, completion: { (result) in
                switch result {
                case .success(let fees):
                    if let fee = fees.first {
                        queue?.saveValue(fee, forKey: saveFeeKey)
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
                                                 _ saveBlockDataKey: String,
                                                 _ completion: @escaping Completion<Bool>) -> Operation {
        
        let getBlockDataOperation = BlockOperation()
        
        getBlockDataOperation.addExecutionBlock { [weak getBlockDataOperation, weak queue, weak self] in
            
            guard getBlockDataOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            
            self?.services.databaseService.getBlockData(completion: { (result) in
                switch result {
                case .success(let blockData):
                    queue?.saveValue(blockData, forKey: saveBlockDataKey)
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
                                            _ saveChainIdKey: String,
                                            _ completion: @escaping Completion<Bool>) -> Operation {
        
        let chainIdOperation = BlockOperation()
        
        chainIdOperation.addExecutionBlock { [weak chainIdOperation, weak queue, weak self] in
            
            guard chainIdOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            
            self?.services.databaseService.getChainId(completion: { (result) in
                switch result {
                case .success(let chainId):
                    queue?.saveValue(chainId, forKey: saveChainIdKey)
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
        
        let bildCreateOperation = BlockOperation()
        
        bildCreateOperation.addExecutionBlock { [weak bildCreateOperation, weak queue, weak self] in
            
            guard bildCreateOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            
            guard let account: Account = queue?.getValue(CreateAssetKeys.account.rawValue) else { return }
            guard var operation: CreateAssetOperation = queue?.getValue(CreateAssetKeys.operation.rawValue) else { return }
            guard let chainId: String = queue?.getValue(CreateAssetKeys.chainId.rawValue) else { return }
            guard let blockData: BlockData = queue?.getValue(CreateAssetKeys.blockData.rawValue) else { return }
            guard let fee: AssetAmount = queue?.getValue(CreateAssetKeys.fee.rawValue) else { return }
            
            if let strongSelf = self,
                !strongSelf.checkAccount(account: account, name: account.name, password: password) {
                
                queue?.cancelAllOperations()
                let result = Result<Bool, ECHOError>(error: ECHOError.invalidCredentials)
                completion(result)
                return
            }
            
            operation.fee = fee
            
            let transaction = Transaction(operations: [operation], blockData: blockData, chainId: chainId)
            
            guard let name = account.name else { return }
            guard let cryptoCore = self?.cryptoCore else { return }
            guard let keyChain = ECHOKeychain(name: name, password: password, type: KeychainType.active, core: cryptoCore) else { return }
            
            do {
                let generator = SignaturesGenerator()
                let signatures = try generator.signTransaction(transaction, privateKeys: [keyChain.raw], cryptoCore: cryptoCore)
                transaction.signatures = signatures
                queue?.saveValue(transaction, forKey: CreateAssetKeys.transaction.rawValue)
            } catch {
                queue?.cancelAllOperations()
                let result = Result<Bool, ECHOError>(error: ECHOError.undefined)
                completion(result)
            }
        }
        
        return bildCreateOperation
    }
    
    fileprivate func issueBildTransactionOperation(_ queue: ECHOQueue,
                                                   _ password: String,
                                                   _ completion: @escaping Completion<Bool>) -> Operation {
        
        let issuebildTransactionOperation = BlockOperation()
        
        issuebildTransactionOperation.addExecutionBlock { [weak issuebildTransactionOperation, weak queue, weak self] in
            
            guard issuebildTransactionOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            
            guard let account: Account = queue?.getValue(IssueAssetKeys.issuerAccount.rawValue) else { return }
            guard var operation: IssueAssetOperation = queue?.getValue(IssueAssetKeys.operation.rawValue) else { return }
            guard let chainId: String = queue?.getValue(IssueAssetKeys.chainId.rawValue) else { return }
            guard let blockData: BlockData = queue?.getValue(IssueAssetKeys.blockData.rawValue) else { return }
            guard let fee: AssetAmount = queue?.getValue(IssueAssetKeys.fee.rawValue) else { return }
            
            operation.fee = fee
            
            let transaction = Transaction(operations: [operation], blockData: blockData, chainId: chainId)
            
            guard let name = account.name else { return }
            guard let cryptoCore = self?.cryptoCore else { return }
            guard let keyChain = ECHOKeychain(name: name, password: password, type: KeychainType.active, core: cryptoCore) else { return }
            
            do {
                let generator = SignaturesGenerator()
                let signatures = try generator.signTransaction(transaction, privateKeys: [keyChain.raw], cryptoCore: cryptoCore)
                transaction.signatures = signatures
                queue?.saveValue(transaction, forKey: CreateAssetKeys.transaction.rawValue)
            } catch {
                queue?.cancelAllOperations()
                let result = Result<Bool, ECHOError>(error: ECHOError.undefined)
                completion(result)
            }
        }
        
        return issuebildTransactionOperation
    }
    
    fileprivate func createSendTransactionOperation(_ queue: ECHOQueue,
                                                    _ getTransactionKey: String,
                                                    _ completion: @escaping Completion<Bool>) -> Operation {
        
        let sendTransactionOperation = BlockOperation()
        
        sendTransactionOperation.addExecutionBlock { [weak sendTransactionOperation, weak queue, weak self] in
            
            guard sendTransactionOperation?.isCancelled == false else { return }
            guard let transction: Transaction = queue?.getValue(getTransactionKey) else { return }
            
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
                                                    nonce: String(format: "%llu", nonce),
                                                    message: message)
        
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
}
