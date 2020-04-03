//
//  FeeFacadeImp.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 27.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Services for FeeFacade
 */
public struct FeeFacadeServices {
    var databaseService: DatabaseApiService
}

/**
    Implementation of [FeeFacade](FeeFacade), [ECHOQueueble](ECHOQueueble)
 */

// swiftlint:disable type_body_length
final public class FeeFacadeImp: FeeFacade, ECHOQueueble {
    
    var queues: [String: ECHOQueue]
    let services: FeeFacadeServices
    let network: ECHONetwork
    let cryptoCore: CryptoCoreComponent
    let abiCoderCore: AbiCoder
    let settings: Settings
    
    init(services: FeeFacadeServices,
         cryptoCore: CryptoCoreComponent,
         network: ECHONetwork,
         abiCoderCore: AbiCoder,
         settings: Settings) {

        self.services = services
        self.network = network
        self.cryptoCore = cryptoCore
        self.abiCoderCore = abiCoderCore
        self.settings = settings
        self.queues = [String: ECHOQueue]()
    }
    
    private enum FeeResultsKeys: String {
        case loadedToAccount
        case loadedFromAccount
        case operation
        case fee
        case registrarAccount
        case receiverContract
        case byteCode
    }
    
    public func getFeeForTransferOperation(fromNameOrId: String,
                                           toNameOrId: String,
                                           amount: UInt,
                                           asset: String,
                                           assetForFee: String?,
                                           completion: @escaping Completion<AssetAmount>) {
        
        // if we don't have assetForFee, we use asset.
        let assetForFee = assetForFee ?? asset
        
        // Validate asset id
        do {
            let validator = IdentifierValidator()
            try validator.validateId(asset, for: .asset)
            try validator.validateId(assetForFee, for: .asset)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<AssetAmount, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        let feeQueue = ECHOQueue()
        addQueue(feeQueue)
        
        // Account
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(fromNameOrId, FeeResultsKeys.loadedFromAccount.rawValue),
                                                                          (toNameOrId, FeeResultsKeys.loadedToAccount.rawValue)])
        let getAccountsOperationInitParams = (feeQueue,
                                             services.databaseService,
                                             getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<AssetAmount>(initParams: getAccountsOperationInitParams,
                                                                  completion: completion)
        
        // Operation
        let bildTransferOperation = createBildTransferOperation(feeQueue, amount, asset, completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (feeQueue,
                                                 services.databaseService,
                                                 Asset(assetForFee),
                                                 FeeResultsKeys.operation.rawValue,
                                                 FeeResultsKeys.fee.rawValue,
                                                 UInt(1))
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<AssetAmount>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: completion)
        
        // FeeCompletion
        let feeCompletionOperation = createFeeComletionOperation(feeQueue, completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: feeQueue)
        
        feeQueue.addOperation(getAccountsOperation)
        feeQueue.addOperation(bildTransferOperation)
        feeQueue.addOperation(getRequiredFeeOperation)
        feeQueue.addOperation(feeCompletionOperation)
        
        feeQueue.addOperation(completionOperation)
    }
    
    public func getFeeForCreateContract(registrarNameOrId: String,
                                        assetId: String,
                                        amount: UInt?,
                                        assetForFee: String?,
                                        byteCode: String,
                                        supportedAssetId: String?,
                                        ethAccuracy: Bool,
                                        parameters: [AbiTypeValueInputModel]?,
                                        completion: @escaping Completion<AssetAmount>) {
        
        var completedBytecode = byteCode
        
        if let parameters = parameters,
            let argumentsString = (try? abiCoderCore.getArguments(valueTypes: parameters))?.hex {
            completedBytecode += argumentsString
        }
        
        getFeeForCreateContract(registrarNameOrId: registrarNameOrId,
                                assetId: assetId,
                                amount: amount,
                                assetForFee: assetForFee,
                                byteCode: completedBytecode,
                                supportedAssetId: supportedAssetId,
                                ethAccuracy: ethAccuracy,
                                completion: completion)
    }
    
    public func getFeeForCreateContract(registrarNameOrId: String,
                                        assetId: String,
                                        amount: UInt?,
                                        assetForFee: String?,
                                        byteCode: String,
                                        supportedAssetId: String?,
                                        ethAccuracy: Bool,
                                        completion: @escaping Completion<AssetAmount>) {
        
        let assetForFee = assetForFee ?? Settings.defaultAsset
        
        // Validate asset id, assetIdForFee
        do {
            let validator = IdentifierValidator()
            try validator.validateId(assetId, for: .asset)
            try validator.validateId(assetForFee, for: .asset)
            
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<AssetAmount, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        let createQueue = ECHOQueue()
        addQueue(createQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(registrarNameOrId, FeeResultsKeys.registrarAccount.rawValue)])
        let getAccountsOperationInitParams = (createQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<AssetAmount>(initParams: getAccountsOperationInitParams,
                                                                          completion: completion)
        
        // Operation
        createQueue.saveValue(byteCode, forKey: FeeResultsKeys.byteCode.rawValue)
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
                                                 FeeResultsKeys.operation.rawValue,
                                                 FeeResultsKeys.fee.rawValue,
                                                 UInt(1))
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<AssetAmount>(initParams: getRequiredFeeOperationInitParams,
                                                                                completion: completion)
        
        // FeeCompletion
        let feeCompletionOperation = createFeeComletionOperation(createQueue, completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: createQueue)
        
        createQueue.addOperation(getAccountsOperation)
        createQueue.addOperation(bildCreateContractOperation)
        createQueue.addOperation(getRequiredFeeOperation)
        createQueue.addOperation(feeCompletionOperation)
        
        createQueue.addOperation(completionOperation)
    }
    
    public func getFeeForCallContractOperation(registrarNameOrId: String,
                                               assetId: String,
                                               amount: UInt?,
                                               assetForFee: String?,
                                               contratId: String,
                                               methodName: String,
                                               methodParams: [AbiTypeValueInputModel],
                                               completion: @escaping Completion<CallContractFee>) {
        
        getFeeForCallContractOperation(registrarNameOrId: registrarNameOrId,
                                       assetId: assetId,
                                       amount: amount,
                                       assetForFee: assetForFee,
                                       contratId: contratId,
                                       executeType: ContractExecuteType.nameAndParams(methodName, methodParams),
                                       completion: completion)
    }
    
    public func getFeeForCallContractOperation(registrarNameOrId: String,
                                               assetId: String,
                                               amount: UInt?,
                                               assetForFee: String?,
                                               contratId: String,
                                               byteCode: String,
                                               completion: @escaping Completion<CallContractFee>) {
        
        getFeeForCallContractOperation(registrarNameOrId: registrarNameOrId,
                                       assetId: assetId,
                                       amount: amount,
                                       assetForFee: assetForFee,
                                       contratId: contratId,
                                       executeType: ContractExecuteType.code(byteCode),
                                       completion: completion)
    }
    
    fileprivate func getFeeForCallContractOperation(registrarNameOrId: String,
                                                    assetId: String,
                                                    amount: UInt?,
                                                    assetForFee: String?,
                                                    contratId: String,
                                                    executeType: ContractExecuteType,
                                                    completion: @escaping Completion<CallContractFee>) {
        
        // if we don't have assetForFee, we use asset.
        let assetForFee = assetForFee ?? assetId
        
        // Validate asset id
        do {
            let validator = IdentifierValidator()
            try validator.validateId(assetId, for: .asset)
            try validator.validateId(assetForFee, for: .asset)
            try validator.validateId(contratId, for: .contract)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<CallContractFee, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        let callQueue = ECHOQueue()
        addQueue(callQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(registrarNameOrId, FeeResultsKeys.registrarAccount.rawValue)])
        let getAccountsOperationInitParams = (callQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<CallContractFee>(initParams: getAccountsOperationInitParams,
                                                                              completion: completion)
        
        // ByteCode
        // ByteCode
        var byteCodeOperation: Operation?
        switch executeType {
        case .code(let code):
            callQueue.saveValue(code, forKey: FeeResultsKeys.byteCode.rawValue)
        case .nameAndParams(let methodName, let methodParams):
            byteCodeOperation = createByteCodeOperation(callQueue, methodName, methodParams, completion)
        }
        
        // Operation
        callQueue.saveValue(Contract(id: contratId), forKey: FeeResultsKeys.receiverContract.rawValue)
        let bildCreateContractOperation = bildCreateCallContractOperation(callQueue, amount ?? 0, assetId, assetForFee, completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (callQueue,
                                                 services.databaseService,
                                                 Asset(assetForFee),
                                                 FeeResultsKeys.operation.rawValue,
                                                 FeeResultsKeys.fee.rawValue,
                                                 settings.callContractFeeMultiplier)
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<CallContractFee>(initParams: getRequiredFeeOperationInitParams,
                                                                                    completion: completion)
        
        // FeeCompletion
        let feeCompletionOperation = createFeeComletionOperation(callQueue, completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: callQueue)
        
        callQueue.addOperation(getAccountsOperation)
        if let byteCodeOperation = byteCodeOperation {
            callQueue.addOperation(byteCodeOperation)
        }
        callQueue.addOperation(bildCreateContractOperation)
        callQueue.addOperation(getRequiredFeeOperation)
        callQueue.addOperation(feeCompletionOperation)
        
        callQueue.addOperation(completionOperation)
    }
    
    public func getFeeForWithdrawEthOperation(nameOrId: String,
                                              toEthAddress: String,
                                              amount: UInt,
                                              assetForFee: String?,
                                              completion: @escaping Completion<AssetAmount>) {
        // if we don't hace assetForFee, we use asset.
        let assetForFee = assetForFee ?? Settings.defaultAsset
        
        // Validate asset id
        do {
            let validator = IdentifierValidator()
            try validator.validateId(assetForFee, for: .asset)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<AssetAmount, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        // Validate Ethereum address
        let ethValidator = ETHAddressValidator(cryptoCore: cryptoCore)
        guard ethValidator.isValidETHAddress(toEthAddress) else {
            let result = Result<AssetAmount, ECHOError>(error: .invalidETHAddress)
            completion(result)
            return
        }
        
        let withdrawalQueue = ECHOQueue()
        addQueue(withdrawalQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(nameOrId, FeeResultsKeys.loadedFromAccount.rawValue)])
        let getAccountsOperationInitParams = (withdrawalQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<AssetAmount>(initParams: getAccountsOperationInitParams,
                                                                          completion: completion)
        
        let bildWithdrawOperation = createBildWithdrawETHOperation(withdrawalQueue, Asset(assetForFee), amount, toEthAddress, completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (withdrawalQueue,
                                                 services.databaseService,
                                                 Asset(assetForFee),
                                                 FeeResultsKeys.operation.rawValue,
                                                 FeeResultsKeys.fee.rawValue,
                                                 UInt(1))
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<AssetAmount>(initParams: getRequiredFeeOperationInitParams,
                                                                                completion: completion)
        
        // FeeCompletion
        let feeCompletionOperation = createFeeComletionOperation(withdrawalQueue, completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: withdrawalQueue)
        
        withdrawalQueue.addOperation(getAccountsOperation)
        withdrawalQueue.addOperation(bildWithdrawOperation)
        withdrawalQueue.addOperation(getRequiredFeeOperation)
        withdrawalQueue.addOperation(feeCompletionOperation)
        
        withdrawalQueue.addOperation(completionOperation)
    }
    
    public func getFeeForWithdrawBtcOperation(nameOrId: String,
                                              toBtcAddress: String,
                                              amount: UInt,
                                              assetForFee: String?,
                                              completion: @escaping Completion<AssetAmount>) {
        // if we don't hace assetForFee, we use asset.
        let assetForFee = assetForFee ?? Settings.defaultAsset
        
        // Validate asset id
        do {
            let validator = IdentifierValidator()
            try validator.validateId(assetForFee, for: .asset)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<AssetAmount, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        let btcValidator = BTCAddressValidator(cryptoCore: cryptoCore)
        guard btcValidator.isValidBTCAddress(toBtcAddress) else {
            let result = Result<AssetAmount, ECHOError>(error: .invalidBTCAddress)
            completion(result)
            return
        }
        
        let withdrawalQueue = ECHOQueue()
        addQueue(withdrawalQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(nameOrId, FeeResultsKeys.loadedFromAccount.rawValue)])
        let getAccountsOperationInitParams = (withdrawalQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<AssetAmount>(initParams: getAccountsOperationInitParams,
                                                                          completion: completion)
        
        let bildWithdrawOperation = createBildWithdrawBTCOperation(withdrawalQueue, Asset(assetForFee), amount, toBtcAddress, completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (withdrawalQueue,
                                                 services.databaseService,
                                                 Asset(assetForFee),
                                                 FeeResultsKeys.operation.rawValue,
                                                 FeeResultsKeys.fee.rawValue,
                                                 UInt(1))
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<AssetAmount>(initParams: getRequiredFeeOperationInitParams,
                                                                                completion: completion)
        
        // FeeCompletion
        let feeCompletionOperation = createFeeComletionOperation(withdrawalQueue, completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: withdrawalQueue)
        
        withdrawalQueue.addOperation(getAccountsOperation)
        withdrawalQueue.addOperation(bildWithdrawOperation)
        withdrawalQueue.addOperation(getRequiredFeeOperation)
        withdrawalQueue.addOperation(feeCompletionOperation)
        
        withdrawalQueue.addOperation(completionOperation)
    }
    
    public func getFeeForWithdrawERC20Operation(nameOrId: String,
                                                toEthAddress: String,
                                                tokenId: String,
                                                value: String,
                                                assetForFee: String?,
                                                completion: @escaping Completion<AssetAmount>) {
        // if we don't hace assetForFee, we use asset.
        let assetForFee = assetForFee ?? Settings.defaultAsset
        
        // Validate asset id and token id
        do {
            let validator = IdentifierValidator()
            try validator.validateId(assetForFee, for: .asset)
            try validator.validateId(tokenId, for: .erc20Token)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<AssetAmount, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        // Validate Ethereum address
        let ethValidator = ETHAddressValidator(cryptoCore: cryptoCore)
        guard ethValidator.isValidETHAddress(toEthAddress) else {
            let result = Result<AssetAmount, ECHOError>(error: .invalidETHAddress)
            completion(result)
            return
        }
        
        let withdrawalQueue = ECHOQueue()
        addQueue(withdrawalQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(nameOrId, FeeResultsKeys.loadedFromAccount.rawValue)])
        let getAccountsOperationInitParams = (withdrawalQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<AssetAmount>(initParams: getAccountsOperationInitParams,
                                                                          completion: completion)
        
        let bildWithdrawOperation = createBildWithdrawERC20Operation(withdrawalQueue, Asset(assetForFee), value, toEthAddress, tokenId, completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (withdrawalQueue,
                                                 services.databaseService,
                                                 Asset(assetForFee),
                                                 FeeResultsKeys.operation.rawValue,
                                                 FeeResultsKeys.fee.rawValue,
                                                 UInt(1))
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<AssetAmount>(initParams: getRequiredFeeOperationInitParams,
                                                                                completion: completion)
        
        // FeeCompletion
        let feeCompletionOperation = createFeeComletionOperation(withdrawalQueue, completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: withdrawalQueue)
        
        withdrawalQueue.addOperation(getAccountsOperation)
        withdrawalQueue.addOperation(bildWithdrawOperation)
        withdrawalQueue.addOperation(getRequiredFeeOperation)
        withdrawalQueue.addOperation(feeCompletionOperation)
        
        withdrawalQueue.addOperation(completionOperation)
    }
    
    fileprivate func createBildTransferOperation(_ queue: ECHOQueue,
                                                 _ amount: UInt,
                                                 _ asset: String,
                                                 _ completion: @escaping Completion<AssetAmount>) -> Operation {
        
        let bildTransferOperation = BlockOperation()
        
        bildTransferOperation.addExecutionBlock { [weak bildTransferOperation, weak queue] in
            
            guard bildTransferOperation?.isCancelled == false else { return }
            
            guard let fromAccount: Account = queue?.getValue(FeeResultsKeys.loadedFromAccount.rawValue) else { return }
            guard let toAccount: Account = queue?.getValue(FeeResultsKeys.loadedFromAccount.rawValue) else { return }
            
            let fee = AssetAmount(amount: 0, asset: Asset(asset))
            let amount = AssetAmount(amount: amount, asset: Asset(asset))
            let transferOperation = TransferOperation(fromAccount: fromAccount,
                                                      toAccount: toAccount,
                                                      transferAmount: amount,
                                                      fee: fee)
            
            queue?.saveValue(transferOperation, forKey: FeeResultsKeys.operation.rawValue)
        }
        
        return bildTransferOperation
    }
    
    fileprivate func createFeeComletionOperation<T>(_ queue: ECHOQueue, _ completion: @escaping Completion<T>) -> Operation {
        
        let feeCompletionOperation = BlockOperation()
        
        feeCompletionOperation.addExecutionBlock { [weak feeCompletionOperation, weak queue] in
            
            guard feeCompletionOperation?.isCancelled == false else { return }
            guard let fee: FeeType = queue?.getValue(FeeResultsKeys.fee.rawValue) else { return }
            
            switch fee {
            case .defaultFee(let assetAmount):
                if let fee = assetAmount as? T {
                    let result = Result<T, ECHOError>(value: fee)
                    completion(result)
                    return
                }
            case .callContractFee(let callContractFee):
                if let fee = callContractFee as? T {
                    let result = Result<T, ECHOError>(value: fee)
                    completion(result)
                    return
                }
            }
            
            let result = Result<T, ECHOError>(error: ECHOError.encodableMapping)
            completion(result)
        }
        
        return feeCompletionOperation
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
            
            queue?.saveValue(hash, forKey: FeeResultsKeys.byteCode.rawValue)
        }
        
        return byteCodeOperation
    }
    
    fileprivate func createBildCreateContractOperation(_ queue: ECHOQueue,
                                                       _ amount: UInt,
                                                       _ assetId: String,
                                                       _ assetForFee: String,
                                                       _ supportedAssetId: String?,
                                                       _ ethAccuracy: Bool,
                                                       _ completion: @escaping Completion<AssetAmount>) -> Operation {
        
        let contractOperation = BlockOperation()
        
        contractOperation.addExecutionBlock { [weak contractOperation, weak queue, weak self] in
            
            guard contractOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let account: Account = queue?.getValue(FeeResultsKeys.registrarAccount.rawValue) else { return }
            guard let byteCode: String = queue?.getValue(FeeResultsKeys.byteCode.rawValue) else { return }
            
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
            
            queue?.saveValue(operation, forKey: FeeResultsKeys.operation.rawValue)
        }
        
        return contractOperation
    }
    
    fileprivate func bildCreateCallContractOperation(_ queue: ECHOQueue,
                                                     _ amount: UInt,
                                                     _ assetId: String,
                                                     _ assetForFee: String,
                                                     _ completion: @escaping Completion<CallContractFee>) -> Operation {
        
        let contractOperation = BlockOperation()
        
        contractOperation.addExecutionBlock { [weak contractOperation, weak queue, weak self] in
            
            guard contractOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let account: Account = queue?.getValue(FeeResultsKeys.registrarAccount.rawValue) else { return }
            guard let byteCode: String = queue?.getValue(FeeResultsKeys.byteCode.rawValue) else { return }
            guard let receiver: Contract = queue?.getValue(FeeResultsKeys.receiverContract.rawValue) else { return }
            
            let operation = CallContractOperation(registrar: account,
                                                  value: AssetAmount(amount: amount, asset: Asset(assetId)),
                                                  gasPrice: 0,
                                                  gas: 11000000,
                                                  code: byteCode,
                                                  callee: receiver,
                                                  fee: AssetAmount(amount: 0, asset: Asset(assetForFee)))
            
            queue?.saveValue(operation, forKey: FeeResultsKeys.operation.rawValue)
        }
        
        return contractOperation
    }
    
    fileprivate func createBildWithdrawETHOperation(_ queue: ECHOQueue,
                                                    _ asset: Asset,
                                                    _ amount: UInt,
                                                    _ toEthAddress: String,
                                                    _ completion: @escaping Completion<AssetAmount>) -> Operation {
        
        let bildWithdrawOperation = BlockOperation()
        
        bildWithdrawOperation.addExecutionBlock { [weak bildWithdrawOperation, weak queue] in
            
            guard bildWithdrawOperation?.isCancelled == false else { return }
            
            guard let account: Account = queue?.getValue(FeeResultsKeys.loadedFromAccount.rawValue) else { return }
            
            let fee = AssetAmount(amount: 0, asset: asset)
            let address = toEthAddress.replacingOccurrences(of: "0x", with: "")
            
            let withdrawOperation = SidechainETHWithdrawOperation(account: account,
                                                                  value: amount,
                                                                  ethAddress: address,
                                                                  fee: fee)
            
            queue?.saveValue(withdrawOperation, forKey: FeeResultsKeys.operation.rawValue)
        }
        
        return bildWithdrawOperation
    }
    
    fileprivate func createBildWithdrawBTCOperation(_ queue: ECHOQueue,
                                                    _ asset: Asset,
                                                    _ amount: UInt,
                                                    _ toBtcAddress: String,
                                                    _ completion: @escaping Completion<AssetAmount>) -> Operation {
        
        let bildWithdrawalOperation = BlockOperation()
        
        bildWithdrawalOperation.addExecutionBlock { [weak bildWithdrawalOperation, weak queue] in
            
            guard bildWithdrawalOperation?.isCancelled == false else { return }
            
            guard let account: Account = queue?.getValue(FeeResultsKeys.loadedFromAccount.rawValue) else { return }
            
            let fee = AssetAmount(amount: 0, asset: asset)
            
            let withdrawalOperation = SidechainBTCWithdrawOperation(account: account,
                                                                    value: amount,
                                                                    btcAddress: toBtcAddress,
                                                                    fee: fee)
            
            queue?.saveValue(withdrawalOperation, forKey: FeeResultsKeys.operation.rawValue)
        }
        
        return bildWithdrawalOperation
    }
    
    fileprivate func createBildWithdrawERC20Operation(
        _ queue: ECHOQueue,
        _ asset: Asset,
        _ value: String,
        _ toEthAddress: String,
        _ tokenId: String,
        _ completion: @escaping Completion<AssetAmount>
    ) -> Operation {
        
        let bildWithdrawOperation = BlockOperation()
        
        bildWithdrawOperation.addExecutionBlock { [weak bildWithdrawOperation, weak queue] in
            
            guard bildWithdrawOperation?.isCancelled == false else { return }
            
            guard let account: Account = queue?.getValue(FeeResultsKeys.loadedFromAccount.rawValue) else { return }
            
            let fee = AssetAmount(amount: 0, asset: asset)
            let address = toEthAddress.replacingOccurrences(of: "0x", with: "")
            let token = ERC20Token(id: tokenId)
            
            let withdrawOperation = SidechainERC20WithdrawTokenOperation(account: account,
                                                                         toEthAddress: address,
                                                                         token: token,
                                                                         value: value,
                                                                         fee: fee)
            
            queue?.saveValue(withdrawOperation, forKey: FeeResultsKeys.operation.rawValue)
        }
        
        return bildWithdrawOperation
    }
}
// swiftlint:enable type_body_length
