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
        case transaciton
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
        
        let getAccountOperation = createGetAccountsOperation(createAssetQueue, nameOrId, completion)
        let createAssetOperation = self.createAssetOperation(createAssetQueue, asset, completion)
        let lastOperation = createLastOperation(queue: createAssetQueue)
        let getRequiredFeeOperation = createGetRequiredFeeOperation(createAssetQueue, completion)
        let getChainIdOperation = createChainIdOperation(createAssetQueue, completion)
        let getBlockDataOperation = createGetBlockDataOperation(createAssetQueue, completion)
        let bildTransactionOperation = createBildTransactionOperation(createAssetQueue, password, completion)
        let sendTransactionOperation = createSendTransactionOperation(createAssetQueue, completion)
        
        createAssetQueue.addOperation(getAccountOperation)
        createAssetQueue.addOperation(createAssetOperation)
        createAssetQueue.addOperation(getRequiredFeeOperation)
        createAssetQueue.addOperation(getChainIdOperation)
        createAssetQueue.addOperation(getBlockDataOperation)
        createAssetQueue.addOperation(bildTransactionOperation)
        createAssetQueue.addOperation(sendTransactionOperation)
        createAssetQueue.addOperation(lastOperation)
    }
    
    public func issueAsset(issuerNameOrId: String, password: String, asset: String,
                           amount: String, destinationIdOrName: String, message: String?,
                           completion: @escaping Completion<Bool>) {
        
    }
    
    public func listAssets(lowerBound: String, limit: Int, completion: @escaping Completion<[Asset]>) {
        services.databaseService.listAssets(lowerBound: lowerBound, limit: limit, completion: completion)
    }
    
    public func getAsset(assetIds: [String], completion: @escaping Completion<[Asset]>) {
        services.databaseService.getAssets(assetIds: assetIds, completion: completion)
    }
    
    fileprivate func createGetAccountsOperation(_ queue: ECHOQueue,
                                                _ nameOrId: String,
                                                _ completion: @escaping Completion<Bool>) -> Operation {
        
        let getAccountsOperation = BlockOperation()
        
        getAccountsOperation.addExecutionBlock { [weak getAccountsOperation, weak queue, weak self] in
            
            guard getAccountsOperation?.isCancelled == false else { return }
            
            self?.services.databaseService.getFullAccount(nameOrIds: [nameOrId], shoudSubscribe: false, completion: { (result) in
                switch result {
                case .success(let accounts):
                    if let account = accounts[nameOrId] {
                        queue?.saveValue(account.account, forKey: CreateAssetKeys.account.rawValue)
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
                                                   _ completion: @escaping Completion<Bool>) -> Operation {
        
        let getRequiredFee = BlockOperation()
        
        getRequiredFee.addExecutionBlock { [weak getRequiredFee, weak queue, weak self] in
            
            guard getRequiredFee?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let operation: CreateAssetOperation = queue?.getValue(CreateAssetKeys.operation.rawValue) else { return }
            
            let asset = Asset(Settings.defaultAsset)
            
            self?.services.databaseService.getRequiredFees(operations: [operation], asset: asset, completion: { (result) in
                switch result {
                case .success(let fees):
                    if let fee = fees.first {
                        queue?.saveValue(fee, forKey: CreateAssetKeys.fee.rawValue)
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
                    queue?.saveValue(blockData, forKey: CreateAssetKeys.blockData.rawValue)
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
                    queue?.saveValue(chainId, forKey: CreateAssetKeys.chainId.rawValue)
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
                queue?.saveValue(transaction, forKey: CreateAssetKeys.transaciton.rawValue)
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
            guard let transction: Transaction = queue?.getValue(CreateAssetKeys.transaciton.rawValue) else { return }
            
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
