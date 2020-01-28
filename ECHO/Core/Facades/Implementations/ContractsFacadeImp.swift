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

// swiftlint:disable function_body_length
// swiftlint:disable type_body_length
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
        case operationId
        case noticeHandler
        case notice
        case noticeError
        case logsHandler
    }
    
    var queues: [String: ECHOQueue]
    let services: ContractsFacadeServices
    let network: ECHONetwork
    let cryptoCore: CryptoCoreComponent
    let abiCoderCore: AbiCoder
    let settings: Settings
    
    public init(services: ContractsFacadeServices,
                cryptoCore: CryptoCoreComponent,
                network: ECHONetwork,
                abiCoder: AbiCoder,
                noticeDelegateHandler: NoticeEventDelegateHandler,
                settings: Settings) {
        
        self.services = services
        self.network = network
        self.cryptoCore = cryptoCore
        self.abiCoderCore = abiCoder
        self.settings = settings
        self.queues = [String: ECHOQueue]()
        noticeDelegateHandler.delegate = self
    }
    
    public func getContractLogs(contractId: String, fromBlock: Int, toBlock: Int, completion: @escaping Completion<[ContractLogEnum]>) {
        
        // Validate historyId
        do {
            let validator = IdentifierValidator()
            try validator.validateId(contractId, for: .contract)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<[ContractLogEnum], ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        let getLogsQueue = ECHOQueue()
        addQueue(getLogsQueue)
        
        // Get logs operation
        let getLogsOperation = createGetContractLogsOperation(getLogsQueue, contractId, fromBlock, toBlock, completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: getLogsQueue)
        
        getLogsQueue.addOperation(getLogsOperation)
        
        //Logs notice handler
        getLogsQueue.saveValue(completion, forKey: ContractKeys.logsHandler.rawValue)
        let waitOperation = createWaitingOperation(getLogsQueue)
        let noticeHandleOperation = createLogsNoticeHandleOperation(getLogsQueue)
        getLogsQueue.addOperation(waitOperation)
        getLogsQueue.addOperation(noticeHandleOperation)
        
        getLogsQueue.addOperation(completionOperation)
    }
    
    public func getContractResult(contractResultId: String, completion: @escaping Completion<ContractResultEnum>) {
        
        // Validate historyId
        do {
            let validator = IdentifierValidator()
            try validator.validateId(contractResultId, for: .contractResult)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<ContractResultEnum, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        services.databaseService.getContractResult(contractResultId: contractResultId, completion: completion)
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
    
    public func getContract(contractId: String, completion: @escaping Completion<ContractStructEnum>) {
        
        // Validate contractId
        do {
            let validator = IdentifierValidator()
            try validator.validateId(contractId, for: .contract)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<ContractStructEnum, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        services.databaseService.getContract(contractId: contractId, completion: completion)
    }
    
    public func createContract(registrarNameOrId: String,
                               wif: String,
                               assetId: String,
                               amount: UInt?,
                               assetForFee: String?,
                               byteCode: String,
                               supportedAssetId: String?,
                               ethAccuracy: Bool,
                               parameters: [AbiTypeValueInputModel]?,
                               completion: @escaping Completion<Bool>,
                               noticeHandler: NoticeHandler?) {
        
        var completedBytecode = byteCode
        
        if let parameters = parameters,
            let argumentsString = (try? abiCoderCore.getArguments(valueTypes: parameters))?.hex {
            completedBytecode += argumentsString
        }
        
        createContract(registrarNameOrId: registrarNameOrId,
                       wif: wif,
                       assetId: assetId,
                       amount: amount,
                       assetForFee: assetForFee,
                       byteCode: completedBytecode,
                       supportedAssetId: supportedAssetId,
                       ethAccuracy: ethAccuracy,
                       completion: completion,
                       noticeHandler: noticeHandler)
    }
    
    public func createContract(registrarNameOrId: String,
                               wif: String,
                               assetId: String,
                               amount: UInt?,
                               assetForFee: String?,
                               byteCode: String,
                               supportedAssetId: String?,
                               ethAccuracy: Bool,
                               completion: @escaping Completion<Bool>,
                               noticeHandler: NoticeHandler?) {
        
        let assetForFee = assetForFee ?? Settings.defaultAsset
        
        // Validate asset id, assetIdForFee
        do {
            let validator = IdentifierValidator()
            try validator.validateId(assetId, for: .asset)
            try validator.validateId(assetForFee, for: .asset)
            
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
        let bildCreateContractOperation = createBildCreateContractOperation(createQueue,
                                                                            amount ?? 0,
                                                                            assetId,
                                                                            assetForFee,
                                                                            supportedAssetId,
                                                                            ethAccuracy,
                                                                            completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (createQueue,
                                                 services.databaseService,
                                                 Asset(assetForFee),
                                                 ContractKeys.operation.rawValue,
                                                 ContractKeys.fee.rawValue,
                                                 UInt(1))
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
                                              saveKey: ContractKeys.transaction.rawValue,
                                              wif: wif,
                                              networkPrefix: network.echorandPrefix.rawValue,
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
                                                 ContractKeys.operationId.rawValue,
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
        
        //Notice handler
        if let noticeHandler = noticeHandler {
            createQueue.saveValue(noticeHandler, forKey: ContractKeys.noticeHandler.rawValue)
            let waitOperation = createWaitingOperation(createQueue)
            let noticeHandleOperation = createNoticeHandleOperation(createQueue)
            createQueue.addOperation(waitOperation)
            createQueue.addOperation(noticeHandleOperation)
        }
        
        createQueue.addOperation(completionOperation)
    }
    
    public func callContract(registrarNameOrId: String,
                             wif: String,
                             assetId: String,
                             amount: UInt?,
                             assetForFee: String?,
                             contratId: String,
                             methodName: String,
                             methodParams: [AbiTypeValueInputModel],
                             completion: @escaping Completion<Bool>,
                             noticeHandler: NoticeHandler?) {
        
        callContract(registrarNameOrId: registrarNameOrId,
                     wif: wif,
                     assetId: assetId,
                     amount: amount,
                     assetForFee: assetForFee,
                     contratId: contratId,
                     executeType: ContractExecuteType.nameAndParams(methodName, methodParams),
                     completion: completion,
                     noticeHandler: noticeHandler)
    }
    
    public func callContract(registrarNameOrId: String,
                             wif: String,
                             assetId: String,
                             amount: UInt?,
                             assetForFee: String?,
                             contratId: String,
                             byteCode: String,
                             completion: @escaping Completion<Bool>,
                             noticeHandler: NoticeHandler?) {
        
        callContract(registrarNameOrId: registrarNameOrId,
                     wif: wif,
                     assetId: assetId,
                     amount: amount,
                     assetForFee: assetForFee,
                     contratId: contratId,
                     executeType: ContractExecuteType.code(byteCode),
                     completion: completion,
                     noticeHandler: noticeHandler)
    }
    
    fileprivate func callContract(registrarNameOrId: String,
                                  wif: String,
                                  assetId: String,
                                  amount: UInt?,
                                  assetForFee: String?,
                                  contratId: String,
                                  executeType: ContractExecuteType,
                                  completion: @escaping Completion<Bool>,
                                  noticeHandler: NoticeHandler?) {
        
        let assetForFee = assetForFee ?? Settings.defaultAsset
        
        // Validate assetId, contratId, assetIdForFee
        do {
            let validator = IdentifierValidator()
            try validator.validateId(assetId, for: .asset)
            try validator.validateId(contratId, for: .contract)
            try validator.validateId(assetForFee, for: .asset)
            
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
        var byteCodeOperation: Operation?
        switch executeType {
        case .code(let code):
            callQueue.saveValue(code, forKey: ContractKeys.byteCode.rawValue)
        case .nameAndParams(let methodName, let methodParams):
            byteCodeOperation = createByteCodeOperation(callQueue, methodName, methodParams, completion)
        }
        
        // Operation
        callQueue.saveValue(Contract(id: contratId), forKey: ContractKeys.receiverContract.rawValue)
        let bildCallContractOperation = createBildCallContractOperation(callQueue,
                                                                        amount ?? 0,
                                                                        assetId,
                                                                        assetForFee,
                                                                        completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (callQueue,
                                                 services.databaseService,
                                                 Asset(assetForFee),
                                                 ContractKeys.operation.rawValue,
                                                 ContractKeys.fee.rawValue,
                                                 settings.callContractFeeMultiplier)
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
                                              saveKey: ContractKeys.transaction.rawValue,
                                              wif: wif,
                                              networkPrefix: network.echorandPrefix.rawValue,
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
                                                 ContractKeys.operationId.rawValue,
                                                 ContractKeys.transaction.rawValue)
        let sendTransactionOperation = SendTransactionQueueOperation(initParams: sendTransacionOperationInitParams,
                                                                     completion: completion)
        
        //Notice handler
        callQueue.saveValue(noticeHandler, forKey: ContractKeys.noticeHandler.rawValue)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: callQueue)
        
        callQueue.addOperation(getAccountsOperation)
        if let byteCodeOperation = byteCodeOperation {
            callQueue.addOperation(byteCodeOperation)
        }
        callQueue.addOperation(bildCallContractOperation)
        callQueue.addOperation(getRequiredFeeOperation)
        callQueue.addOperation(getChainIdOperation)
        callQueue.addOperation(getBlockDataOperation)
        callQueue.addOperation(bildTransactionOperation)
        callQueue.addOperation(sendTransactionOperation)
        
        //Notice handler
        if let noticeHandler = noticeHandler {
            callQueue.saveValue(noticeHandler, forKey: ContractKeys.noticeHandler.rawValue)
            let waitOperation = createWaitingOperation(callQueue)
            let noticeHandleOperation = createNoticeHandleOperation(callQueue)
            callQueue.addOperation(waitOperation)
            callQueue.addOperation(noticeHandleOperation)
        }
        
        callQueue.addOperation(completionOperation)
    }
    
    public func queryContract(registrarNameOrId: String,
                              amount: UInt,
                              assetId: String,
                              contratId: String,
                              methodName: String,
                              methodParams: [AbiTypeValueInputModel],
                              completion: @escaping Completion<String>) {
        
        queryContract(registrarNameOrId: registrarNameOrId,
                      amount: amount,
                      assetId: assetId,
                      contratId: contratId,
                      executeType: ContractExecuteType.nameAndParams(methodName, methodParams),
                      completion: completion)
    }
    
    public func queryContract(registrarNameOrId: String,
                              amount: UInt,
                              assetId: String,
                              contratId: String,
                              byteCode: String,
                              completion: @escaping Completion<String>) {
        
        queryContract(registrarNameOrId: registrarNameOrId,
                      amount: amount,
                      assetId: assetId,
                      contratId: contratId,
                      executeType: ContractExecuteType.code(byteCode),
                      completion: completion)
    }
    
    fileprivate func queryContract(registrarNameOrId: String,
                                   amount: UInt,
                                   assetId: String,
                                   contratId: String,
                                   executeType: ContractExecuteType,
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
        var byteCodeOperation: Operation?
        switch executeType {
        case .code(let code):
            queryQueue.saveValue(code, forKey: ContractKeys.byteCode.rawValue)
        case .nameAndParams(let methodName, let methodParams):
            byteCodeOperation = createByteCodeOperation(queryQueue, methodName, methodParams, completion)
        }
        
        // Operation
        queryQueue.saveValue(Contract(id: contratId), forKey: ContractKeys.receiverContract.rawValue)
        let callContractNoChangigState = createBildCallContractNoChangingState(queryQueue, amount, assetId, completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: queryQueue)
        
        queryQueue.addOperation(getAccountsOperation)
        if let byteCodeOperation = byteCodeOperation {
            queryQueue.addOperation(byteCodeOperation)
        }
        queryQueue.addOperation(callContractNoChangigState)
        queryQueue.addOperation(completionOperation)
    }
    
    fileprivate func createBildCallContractOperation(_ queue: ECHOQueue,
                                                     _ amount: UInt,
                                                     _ assetId: String,
                                                     _ assetForFee: String,
                                                     _ completion: @escaping Completion<Bool>) -> Operation {
        
        let contractOperation = BlockOperation()
        
        contractOperation.addExecutionBlock { [weak contractOperation, weak queue, weak self] in
            
            guard contractOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let account: Account = queue?.getValue(ContractKeys.registrarAccount.rawValue) else { return }
            guard let byteCode: String = queue?.getValue(ContractKeys.byteCode.rawValue) else { return }
            guard let receiver: Contract = queue?.getValue(ContractKeys.receiverContract.rawValue) else { return }
            
            let operation = CallContractOperation(registrar: account,
                                                  value: AssetAmount(amount: amount, asset: Asset(assetId)),
                                                  gasPrice: 0,
                                                  gas: 11000000,
                                                  code: byteCode,
                                                  callee: receiver,
                                                  fee: AssetAmount(amount: 0, asset: Asset(assetForFee)))
            
            queue?.saveValue(operation, forKey: ContractKeys.operation.rawValue)
        }
        
        return contractOperation
    }
    
    fileprivate func createBildCreateContractOperation(_ queue: ECHOQueue,
                                                       _ amount: UInt,
                                                       _ assetId: String,
                                                       _ assetForFee: String,
                                                       _ supportedAssetId: String?,
                                                       _ ethAccuracy: Bool,
                                                       _ completion: @escaping Completion<Bool>) -> Operation {
        
        let contractOperation = BlockOperation()
        
        contractOperation.addExecutionBlock { [weak contractOperation, weak queue, weak self] in
            
            guard contractOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let account: Account = queue?.getValue(ContractKeys.registrarAccount.rawValue) else { return }
            guard let byteCode: String = queue?.getValue(ContractKeys.byteCode.rawValue) else { return }
            
            var supportedAsset: Asset?
            if let supportedAssetId = supportedAssetId {
                supportedAsset = Asset(supportedAssetId)
            }
            
            let operation = CreateContractOperation(registrar: account,
                                                    value: AssetAmount(amount: amount, asset: Asset(assetId)),
                                                    code: byteCode,
                                                    fee: AssetAmount(amount: 0, asset: Asset(assetForFee)),
                                                    supportedAsset: supportedAsset,
                                                    ethAccuracy: ethAccuracy)
            
            queue?.saveValue(operation, forKey: ContractKeys.operation.rawValue)
        }
        
        return contractOperation
    }
    
    fileprivate func createNoticeHandleOperation(_ queue: ECHOQueue) -> Operation {
        
        let noticeOperation = BlockOperation()
        
        noticeOperation.addExecutionBlock { [weak noticeOperation, weak queue, weak self] in
            
            guard noticeOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let noticeHandler: NoticeHandler = queue?.getValue(ContractKeys.noticeHandler.rawValue) else { return }
            
            if let notice: ECHONotification = queue?.getValue(ContractKeys.notice.rawValue) {
                let result = Result<ECHONotification, ECHOError>(value: notice)
                noticeHandler(result)
                return
            }
            
            if let noticeError: ECHOError = queue?.getValue(ContractKeys.noticeError.rawValue) {
                let result = Result<ECHONotification, ECHOError>(error: noticeError)
                noticeHandler(result)
                return
            }
        }
        
        return noticeOperation
    }
    
    fileprivate func createLogsNoticeHandleOperation(_ queue: ECHOQueue) -> Operation {
        
        let noticeOperation = BlockOperation()
        
        noticeOperation.addExecutionBlock { [weak noticeOperation, weak queue, weak self] in
            
            guard noticeOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let logsHandler: Completion<[ContractLogEnum]> = queue?.getValue(ContractKeys.logsHandler.rawValue) else { return }
            
            if let notice: ECHONotification = queue?.getValue(ContractKeys.notice.rawValue) {
                print(notice)

                switch notice.params {
                case .array(let array):
                    if let logsAny = array.last,
                        let paramsData = try? JSONSerialization.data(withJSONObject: logsAny, options: []),
                        let paramsArray = try? JSONDecoder().decode([[ContractLogEnum]].self, from: paramsData),
                        let logs = paramsArray.first {
                        let result = Result<[ContractLogEnum], ECHOError>(value: logs)
                        logsHandler(result)
                    } else {
                        let result = Result<[ContractLogEnum], ECHOError>(error: .encodableMapping)
                        logsHandler(result)
                    }
                default:
                    let result = Result<[ContractLogEnum], ECHOError>(error: .encodableMapping)
                    logsHandler(result)
                }
                return
            }
            
            if let noticeError: ECHOError = queue?.getValue(ContractKeys.noticeError.rawValue) {
                let result = Result<[ContractLogEnum], ECHOError>(error: noticeError)
                logsHandler(result)
                return
            }
        }
        
        return noticeOperation
    }
    
    fileprivate func createWaitingOperation(_ queue: ECHOQueue) -> Operation {
        
        let waitingOperation = BlockOperation()
        
        waitingOperation.addExecutionBlock { [weak waitingOperation, weak queue, weak self] in
            
            guard waitingOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            queue?.waitStartNextOperation()
        }
        
        return waitingOperation
    }
    
    fileprivate func createBildCallContractNoChangingState(_ queue: ECHOQueue,
                                                           _ amount: UInt,
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
                                                                       amount: amount,
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
    
    fileprivate func createGetContractLogsOperation(_ queue: ECHOQueue,
                                                    _ contractId: String,
                                                    _ fromBlock: Int,
                                                    _ toBlock: Int,
                                                    _ completion: @escaping Completion<[ContractLogEnum]>) -> Operation {
        
        let getLogsOperation = BlockOperation()
        
        getLogsOperation.addExecutionBlock { [weak getLogsOperation, weak queue, weak self] in
            
            guard getLogsOperation?.isCancelled == false else { return }
            guard let strongSelf = self else { return }
            
            let operationId = strongSelf.services.databaseService.getContractLogs(contractId: contractId,
                                                                                  fromBlock: fromBlock,
                                                                                  toBlock: toBlock,
                                                                                  completion: { [weak queue] result in
                switch result {
                case .success:
                    print("Request for logs contract send successful")
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<[ContractLogEnum], ECHOError>(error: error)
                    completion(result)
                }
                
                queue?.startNextOperation()
            })
            
            queue?.saveValue(operationId, forKey: ContractKeys.operationId.rawValue)
            queue?.waitStartNextOperation()
        }
        
        return getLogsOperation
    }
}
// swiftlint:enable function_body_length
// swiftlint:enable type_body_length

extension ContractsFacadeImp: NoticeEventDelegate {
    
    public func didReceiveNotification(notification: ECHONotification) {
        
        switch notification.params {
        case .array(let array):
            if let noticeOperationId = array.first as? Int {
                
                for queue in queues.values {
                    
                    if let queueTransferOperationId: Int = queue.getValue(ContractKeys.operationId.rawValue),
                        queueTransferOperationId == noticeOperationId {
                        queue.saveValue(notification, forKey: ContractKeys.notice.rawValue)
                        queue.startNextOperation()
                    }
                }
            }
        default:
            break
        }
    }
    
    public func didAllNoticesLost() {
        for queue in queues.values {
            queue.saveValue(ECHOError.connectionLost, forKey: ContractKeys.noticeError.rawValue)
            queue.startNextOperation()
        }
    }
}
