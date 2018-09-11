//
//  ContractsFacadeImp.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 10.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Services for TransactionFacade
 */
public struct ContractsFacadeServices {
    var databaseService: DatabaseApiService
    var networkBroadcastService: NetworkBroadcastApiService
}

/**
    Implementation of [ContractsFacade](ContractsFacade), [ECHOQueueble](ECHOQueueble)
 */
final public class ContractsFacadeImp: ContractsFacade, ECHOQueueble {
    
    var queues: [ECHOQueue]
    let services: ContractsFacadeServices
    let network: Network
    let cryptoCore: CryptoCoreComponent
    
    public init(services: ContractsFacadeServices, cryptoCore: CryptoCoreComponent, network: Network) {
        
        self.services = services
        self.network = network
        self.cryptoCore = cryptoCore
        self.queues = [ECHOQueue]()
    }
    
    public func getContractResult(historyId: String, completion: @escaping Completion<ContractResult>) {
        
        services.databaseService.getContractResult(historyId: historyId, completion: completion)
    }
    
    public func getContracts(contractIds: [String], completion: @escaping Completion<[ContractInfo]>) {
        
        services.databaseService.getContracts(contractIds: contractIds, completion: completion)
    }
    
    public func getAllContracts(completion: @escaping Completion<[ContractInfo]>) {
        
        services.databaseService.getAllContracts(completion: completion)
    }
    
    public func getContract(contractId: String, completion: @escaping Completion<ContractStruct>) {
        
        services.databaseService.getContract(contractId: contractId, completion: completion)
    }
    
    private enum CreateContractKeys: String {
        case registrarAccount
        case operation
        case blockData
        case chainId
        case fee
        case transaction
    }
    
    public func createContract(registrarNameOrId: String,
                               password: String,
                               assetId: String,
                               byteCode: String,
                               completion: @escaping Completion<Bool>) {
        
        let createQueue = ECHOQueue()
        addQueue(createQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(registrarNameOrId, CreateContractKeys.registrarAccount.rawValue)])
        let getAccountsOperationInitParams = (createQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<Bool>(initParams: getAccountsOperationInitParams,
                                                                   completion: completion)
        
        // Operation
        let bildCreateContractOperation = createBildCreateContractOperation(createQueue, assetId, byteCode, completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (createQueue,
                                                 services.databaseService,
                                                 Asset(Settings.defaultAsset),
                                                 CreateContractKeys.operation.rawValue,
                                                 CreateContractKeys.fee.rawValue)
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<Bool>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: completion)
        
        // ChainId
        let getChainIdInitParams = (createQueue, services.databaseService, CreateContractKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<Bool>(initParams: getChainIdInitParams,
                                                                 completion: completion)
        
        // BlockData
        let getBlockDataInitParams = (createQueue, services.databaseService, CreateContractKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<Bool>(initParams: getBlockDataInitParams,
                                                                     completion: completion)
        
        // Transaciton
        let transactionOperationInitParams = (queue: createQueue,
                                              cryptoCore: cryptoCore,
                                              keychainType: KeychainType.active,
                                              saveKey: CreateContractKeys.transaction.rawValue,
                                              password: password,
                                              networkPrefix: network.prefix.rawValue,
                                              fromAccountKey: CreateContractKeys.registrarAccount.rawValue,
                                              operationKey: CreateContractKeys.operation.rawValue,
                                              chainIdKey: CreateContractKeys.chainId.rawValue,
                                              blockDataKey: CreateContractKeys.blockData.rawValue,
                                              feeKey: CreateContractKeys.fee.rawValue)
        let bildTransactionOperation = GetTransactionQueueOperation<Bool>(initParams: transactionOperationInitParams,
                                                                          completion: completion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (createQueue,
                                                 services.networkBroadcastService,
                                                 CreateContractKeys.transaction.rawValue)
        let sendTransactionOperation = SendTransactionQueueOperation(initParams: sendTransacionOperationInitParams,
                                                                     completion: completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: createQueue)
        
        createQueue.addOperation(getAccountsOperation)
        createQueue.addOperation(bildCreateContractOperation)
        createQueue.addOperation(getRequiredFeeOperation)
        createQueue.addOperation(getChainIdOperation)
        createQueue.addOperation(getBlockDataOperation)
        createQueue.addOperation(bildTransactionOperation)
        createQueue.addOperation(sendTransactionOperation)
        createQueue.setCompletionOperation(completionOperation)
    }
    
    fileprivate func createBildCreateContractOperation(_ queue: ECHOQueue,
                                                       _ assetId: String,
                                                       _ byteCode: String,
                                                       _ completion: @escaping Completion<Bool>) -> Operation {
        
        let createContractOperation = BlockOperation()
        
        createContractOperation.addExecutionBlock { [weak createContractOperation, weak queue, weak self] in
            
            guard createContractOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let account: Account = queue?.getValue(CreateContractKeys.registrarAccount.rawValue) else { return }
            
            let operaion = ContractOperation(registrar: account,
                                             asset: Asset(assetId),
                                             value: 0,
                                             gasPrice: 0,
                                             gas: 1000000,
                                             code: byteCode,
                                             receiver: nil,
                                             fee: AssetAmount(amount: 0, asset: Asset(Settings.defaultAsset)))
            
            queue?.saveValue(operaion, forKey: CreateContractKeys.operation.rawValue)
        }
        
        return createContractOperation
    }
}
