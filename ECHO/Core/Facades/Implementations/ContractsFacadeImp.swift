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
    
    private enum ContractKeys: String {
        case registrarAccount
        case receiverContract
        case byteCode
        case operation
        case blockData
        case chainId
        case fee
        case transaction
    }
    
    var queues: [ECHOQueue]
    let services: ContractsFacadeServices
    let network: ECHONetwork
    let cryptoCore: CryptoCoreComponent
    let abiCoderCore: AbiCoder
    
    public init(services: ContractsFacadeServices, cryptoCore: CryptoCoreComponent, network: ECHONetwork, abiCoder: AbiCoder) {
        
        self.services = services
        self.network = network
        self.cryptoCore = cryptoCore
        self.abiCoderCore = abiCoder
        self.queues = [ECHOQueue]()
    }
    
    public func getContractResult(historyId: String, completion: @escaping Completion<ContractResult>) {
        
        // Validate historyId
        do {
            let validator = IdentifierValidator()
            try validator.validateId(historyId, for: .contractResult)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<ContractResult, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        services.databaseService.getContractResult(historyId: historyId, completion: completion)
    }
    
    public func getContracts(contractIds: [String], completion: @escaping Completion<[ContractInfo]>) {
        
        // Validate contractIds
        do {
            let validator = IdentifierValidator()
            for contractId in contractIds {
                try validator.validateId(contractId, for: .contract)
            }
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<[ContractInfo], ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        services.databaseService.getContracts(contractIds: contractIds, completion: completion)
    }
    
    public func getAllContracts(completion: @escaping Completion<[ContractInfo]>) {
        
        services.databaseService.getAllContracts(completion: completion)
    }
    
    public func getContract(contractId: String, completion: @escaping Completion<ContractStruct>) {
        
        // Validate contractId
        do {
            let validator = IdentifierValidator()
            try validator.validateId(contractId, for: .contract)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<ContractStruct, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        services.databaseService.getContract(contractId: contractId, completion: completion)
    }
    
    public func createContract(registrarNameOrId: String,
                               password: String,
                               assetId: String,
                               byteCode: String,
                               completion: @escaping Completion<Bool>) {
        
        // Validate asset id
        do {
            let validator = IdentifierValidator()
            try validator.validateId(assetId, for: .asset)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<Bool, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        let createQueue = ECHOQueue()
        addQueue(createQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(registrarNameOrId, ContractKeys.registrarAccount.rawValue)])
        let getAccountsOperationInitParams = (createQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<Bool>(initParams: getAccountsOperationInitParams,
                                                                   completion: completion)
        
        // Operation
        createQueue.saveValue(byteCode, forKey: ContractKeys.byteCode.rawValue)
        let bildCreateContractOperation = createBildContractOperation(createQueue, assetId, completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (createQueue,
                                                 services.databaseService,
                                                 Asset(Settings.defaultAsset),
                                                 ContractKeys.operation.rawValue,
                                                 ContractKeys.fee.rawValue)
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<Bool>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: completion)
        
        // ChainId
        let getChainIdInitParams = (createQueue, services.databaseService, ContractKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<Bool>(initParams: getChainIdInitParams,
                                                                 completion: completion)
        
        // BlockData
        let getBlockDataInitParams = (createQueue, services.databaseService, ContractKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<Bool>(initParams: getBlockDataInitParams,
                                                                     completion: completion)
        
        // Transaciton
        let transactionOperationInitParams = (queue: createQueue,
                                              cryptoCore: cryptoCore,
                                              keychainType: KeychainType.active,
                                              saveKey: ContractKeys.transaction.rawValue,
                                              password: password,
                                              networkPrefix: network.prefix.rawValue,
                                              fromAccountKey: ContractKeys.registrarAccount.rawValue,
                                              operationKey: ContractKeys.operation.rawValue,
                                              chainIdKey: ContractKeys.chainId.rawValue,
                                              blockDataKey: ContractKeys.blockData.rawValue,
                                              feeKey: ContractKeys.fee.rawValue)
        let bildTransactionOperation = GetTransactionQueueOperation<Bool>(initParams: transactionOperationInitParams,
                                                                          completion: completion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (createQueue,
                                                 services.networkBroadcastService,
                                                 ContractKeys.transaction.rawValue)
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
    
    public func callContract(registrarNameOrId: String,
                             password: String,
                             assetId: String,
                             contratId: String,
                             methodName: String,
                             methodParams: [AbiTypeValueInputModel],
                             completion: @escaping (Result<Bool, ECHOError>) -> Void) {
     
        // Validate assetId, contratId
        do {
            let validator = IdentifierValidator()
            try validator.validateId(assetId, for: .asset)
            try validator.validateId(contratId, for: .contract)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<Bool, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        let callQueue = ECHOQueue()
        addQueue(callQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(registrarNameOrId, ContractKeys.registrarAccount.rawValue)])
        let getAccountsOperationInitParams = (callQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<Bool>(initParams: getAccountsOperationInitParams,
                                                                   completion: completion)
        
        // ByteCode
        let byteCodeOperation = createByteCodeOperation(callQueue, methodName, methodParams, completion)
        
        // Operation
        callQueue.saveValue(Contract(id: contratId), forKey: ContractKeys.receiverContract.rawValue)
        let bildCreateContractOperation = createBildContractOperation(callQueue, assetId, completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (callQueue,
                                                 services.databaseService,
                                                 Asset(Settings.defaultAsset),
                                                 ContractKeys.operation.rawValue,
                                                 ContractKeys.fee.rawValue)
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<Bool>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: completion)
        
        // ChainId
        let getChainIdInitParams = (callQueue, services.databaseService, ContractKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<Bool>(initParams: getChainIdInitParams,
                                                                 completion: completion)
        
        // BlockData
        let getBlockDataInitParams = (callQueue, services.databaseService, ContractKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<Bool>(initParams: getBlockDataInitParams,
                                                                     completion: completion)
        
        // Transaciton
        let transactionOperationInitParams = (queue: callQueue,
                                              cryptoCore: cryptoCore,
                                              keychainType: KeychainType.active,
                                              saveKey: ContractKeys.transaction.rawValue,
                                              password: password,
                                              networkPrefix: network.prefix.rawValue,
                                              fromAccountKey: ContractKeys.registrarAccount.rawValue,
                                              operationKey: ContractKeys.operation.rawValue,
                                              chainIdKey: ContractKeys.chainId.rawValue,
                                              blockDataKey: ContractKeys.blockData.rawValue,
                                              feeKey: ContractKeys.fee.rawValue)
        let bildTransactionOperation = GetTransactionQueueOperation<Bool>(initParams: transactionOperationInitParams,
                                                                          completion: completion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (callQueue,
                                                 services.networkBroadcastService,
                                                 ContractKeys.transaction.rawValue)
        let sendTransactionOperation = SendTransactionQueueOperation(initParams: sendTransacionOperationInitParams,
                                                                     completion: completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: callQueue)
        
        callQueue.addOperation(getAccountsOperation)
        callQueue.addOperation(byteCodeOperation)
        callQueue.addOperation(bildCreateContractOperation)
        callQueue.addOperation(getRequiredFeeOperation)
        callQueue.addOperation(getChainIdOperation)
        callQueue.addOperation(getBlockDataOperation)
        callQueue.addOperation(bildTransactionOperation)
        callQueue.addOperation(sendTransactionOperation)
        callQueue.setCompletionOperation(completionOperation)
    }
    
    public func queryContract(registrarNameOrId: String,
                              assetId: String,
                              contratId: String,
                              methodName: String,
                              methodParams: [AbiTypeValueInputModel],
                              completion: @escaping Completion<String>) {
        
        // Validate assetId, contratId
        do {
            let validator = IdentifierValidator()
            try validator.validateId(assetId, for: .asset)
            try validator.validateId(contratId, for: .contract)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<String, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        let queryQueue = ECHOQueue()
        addQueue(queryQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(registrarNameOrId, ContractKeys.registrarAccount.rawValue)])
        let getAccountsOperationInitParams = (queryQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<String>(initParams: getAccountsOperationInitParams,
                                                                   completion: completion)
        
        // ByteCode
        let byteCodeOperation = createByteCodeOperation(queryQueue, methodName, methodParams, completion)
        
        // Operation
        queryQueue.saveValue(Contract(id: contratId), forKey: ContractKeys.receiverContract.rawValue)
        let callContractNoChangigState = createBildCallContractNoChangingState(queryQueue, assetId, completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: queryQueue)
        
        queryQueue.addOperation(getAccountsOperation)
        queryQueue.addOperation(byteCodeOperation)
        queryQueue.addOperation(callContractNoChangigState)
        queryQueue.setCompletionOperation(completionOperation)
    }
    
    fileprivate func createBildContractOperation(_ queue: ECHOQueue,
                                                 _ assetId: String,
                                                 _ completion: @escaping Completion<Bool>) -> Operation {
        
        let contractOperation = BlockOperation()
        
        contractOperation.addExecutionBlock { [weak contractOperation, weak queue, weak self] in
            
            guard contractOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let account: Account = queue?.getValue(ContractKeys.registrarAccount.rawValue) else { return }
            guard let byteCode: String = queue?.getValue(ContractKeys.byteCode.rawValue) else { return }
            
            let receive: Contract? = queue?.getValue(ContractKeys.receiverContract.rawValue)
            
            let operaion = ContractOperation(registrar: account,
                                             asset: Asset(assetId),
                                             value: 0,
                                             gasPrice: 0,
                                             gas: 1000000,
                                             code: byteCode,
                                             receiver: receive,
                                             fee: AssetAmount(amount: 0, asset: Asset(Settings.defaultAsset)))
            
            queue?.saveValue(operaion, forKey: ContractKeys.operation.rawValue)
        }
        
        return contractOperation
    }
    
    fileprivate func createBildCallContractNoChangingState(_ queue: ECHOQueue,
                                                           _ assetId: String,
                                                           _ completion: @escaping Completion<String>) -> Operation {
        let contractOperation = BlockOperation()
        
        contractOperation.addExecutionBlock { [weak contractOperation, weak queue, weak self] in
            
            guard contractOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let account: Account = queue?.getValue(ContractKeys.registrarAccount.rawValue) else { return }
            guard let byteCode: String = queue?.getValue(ContractKeys.byteCode.rawValue) else { return }
            guard let receive: Contract = queue?.getValue(ContractKeys.receiverContract.rawValue) else { return }
            
            self?.services.databaseService.callContractNoChangingState(contract: receive,
                                                                       asset: Asset(assetId),
                                                                       account: account,
                                                                       contractCode: byteCode,
                                                                       completion: completion)
            
        }
        
        return contractOperation
    }
    
    fileprivate func createByteCodeOperation<T>(_ queue: ECHOQueue,
                                                _ methodName: String,
                                                _ methodParams: [AbiTypeValueInputModel],
                                                _ completion: @escaping Completion<T>) -> Operation {
        
        let byteCodeOperation = BlockOperation()
        
        byteCodeOperation.addExecutionBlock { [weak byteCodeOperation, weak queue, weak self] in
            
            guard byteCodeOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            
            guard let hash = try? self?.abiCoderCore.getStringHash(funcName: methodName, param: methodParams) else {
                
                queue?.cancelAllOperations()
                let result = Result<T, ECHOError>(error: ECHOError.abiCoding)
                completion(result)
                return
            }
            
            queue?.saveValue(hash, forKey: ContractKeys.byteCode.rawValue)
        }
        
        return byteCodeOperation
    }
}
