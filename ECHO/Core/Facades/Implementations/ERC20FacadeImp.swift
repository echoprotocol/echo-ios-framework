//
//  ERC20FacadeImp.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 29.11.2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
 Services for ERC20Facade
 */
public struct ERC20FacadeServices {
    var databaseService: DatabaseApiService
    var networkBroadcastService: NetworkBroadcastApiService
}

/**
 Implementation of [ERC20Facade](ERC20Facade), [ECHOQueueble](ECHOQueueble)
 */
final public class ERC20FacadeImp: ERC20Facade, ECHOQueueble, NoticeEventDelegate {
    public var queues: [String: ECHOQueue]
    let services: ERC20FacadeServices
    let network: ECHONetwork
    let cryptoCore: CryptoCoreComponent
    let transactionExpirationOffset: TimeInterval
    
    public init(services: ERC20FacadeServices,
                cryptoCore: CryptoCoreComponent,
                network: ECHONetwork,
                noticeDelegateHandler: NoticeEventDelegateHandler,
                transactionExpirationOffset: TimeInterval) {
        
        self.services = services
        self.network = network
        self.cryptoCore = cryptoCore
        self.queues = [String: ECHOQueue]()
        self.transactionExpirationOffset = transactionExpirationOffset
        noticeDelegateHandler.delegate = self
    }
    
    public func getERC20Token(tokenAddress: String, completion: @escaping Completion<ERC20Token?>) {
        
        // Validate Ethereum address
        let ethValidator = ETHAddressValidator(cryptoCore: cryptoCore)
        guard ethValidator.isValidETHAddress(tokenAddress) else {
            let result = Result<ERC20Token?, ECHOError>(error: .invalidETHAddress)
            completion(result)
            return
        }
        
        let address = tokenAddress.replacingOccurrences(of: "0x", with: "")
        services.databaseService.getERC20Token(tokenAddressOrId: address, completion: completion)
    }
    
    public func getERC20Token(tokenId: String, completion: @escaping Completion<ERC20Token?>) {
        // Validate tokenId
        do {
            let validator = IdentifierValidator()
            try validator.validateId(tokenId, for: .erc20Token)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<ERC20Token?, ECHOError>(error: echoError)
            completion(result)
            return
        }
        services.databaseService.getERC20Token(tokenAddressOrId: tokenId, completion: completion)
    }
    
    public func checkERC20Token(contractId: String, completion: @escaping Completion<Bool>) {
        
        // Validate contract id
        do {
            let validator = IdentifierValidator()
            try validator.validateId(contractId, for: .contract)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<Bool, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        services.databaseService.checkERC20Token(contractId: contractId, completion: completion)
    }
    
    public func getERC20AccountDeposits(nameOrId: String, completion: @escaping Completion<[ERC20Deposit]>) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrId], shoudSubscribe: false) { [weak self] (result) in
            
            switch result {
            case .success(let accounts):
                guard let account = accounts[nameOrId] else {
                    let result = Result<[ERC20Deposit], ECHOError>(error: .resultNotFound)
                    completion(result)
                    return
                }
                
                self?.services.databaseService.getERC20AccountDeposits(accountId: account.account.id,
                                                                       completion: { result in
                    switch result {
                    case .success(let deposits):
                        let result = Result<[ERC20Deposit], ECHOError>(value: deposits)
                        completion(result)
                        
                    case .failure(let error):
                        let result = Result<[ERC20Deposit], ECHOError>(error: error)
                        completion(result)
                    }
                })
                
            case .failure(let error):
                let result = Result<[ERC20Deposit], ECHOError>(error: error)
                completion(result)
            }
        }
    }
    
    public func getERC20AccountWithdrawals(nameOrId: String, completion: @escaping Completion<[ERC20Withdrawal]>) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrId], shoudSubscribe: false) { [weak self] (result) in
            
            switch result {
            case .success(let accounts):
                guard let account = accounts[nameOrId] else {
                    let result = Result<[ERC20Withdrawal], ECHOError>(error: .resultNotFound)
                    completion(result)
                    return
                }
                
                self?.services.databaseService.getERC20AccountWithdrawals(accountId: account.account.id,
                                                                          completion: { result in
                    switch result {
                    case .success(let withdrawals):
                        let result = Result<[ERC20Withdrawal], ECHOError>(value: withdrawals)
                        completion(result)
                        
                    case .failure(let error):
                        let result = Result<[ERC20Withdrawal], ECHOError>(error: error)
                        completion(result)
                    }
                })
                
            case .failure(let error):
                let result = Result<[ERC20Withdrawal], ECHOError>(error: error)
                completion(result)
            }
        }
    }
    
    private enum ERC20FacadeResultKeys: String {
        case loadedAccount
        case blockData
        case chainId
        case operation
        case fee
        case transaction
    }
    
    // swiftlint:disable function_body_length
    public func registerERC20Token(nameOrId: String,
                                   wif: String,
                                   tokenAddress: String,
                                   tokenName: String,
                                   tokenSymbol: String,
                                   tokenDecimals: UInt8,
                                   assetForFee: String?,
                                   sendCompletion: @escaping Completion<Void>,
                                   confirmNoticeHandler: NoticeHandler?) {
        
        // if we don't hace assetForFee, we use asset.
        let assetForFee = assetForFee ?? Settings.defaultAsset
        
        // Validate asset id
        do {
            let validator = IdentifierValidator()
            try validator.validateId(assetForFee, for: .asset)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<Void, ECHOError>(error: echoError)
            sendCompletion(result)
            return
        }
        
        // Validate Ethereum address
        let ethValidator = ETHAddressValidator(cryptoCore: cryptoCore)
        guard ethValidator.isValidETHAddress(tokenAddress) else {
            let result = Result<Void, ECHOError>(error: .invalidETHAddress)
            sendCompletion(result)
            return
        }
        
        let registerQueue = ECHOQueue()
        addQueue(registerQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(nameOrId, ERC20FacadeResultKeys.loadedAccount.rawValue)])
        let getAccountsOperationInitParams = (registerQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<Void>(initParams: getAccountsOperationInitParams,
                                                                   completion: sendCompletion)
        
        let bildRegisterOperation = createBildRegisterOperation(registerQueue, Asset(assetForFee), tokenAddress,
                                                                tokenName, tokenSymbol, tokenDecimals, sendCompletion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (registerQueue,
                                                 services.databaseService,
                                                 Asset(assetForFee),
                                                 ERC20FacadeResultKeys.operation.rawValue,
                                                 ERC20FacadeResultKeys.fee.rawValue,
                                                 UInt(1))
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<Void>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: sendCompletion)
        
        // ChainId
        let getChainIdInitParams = (registerQueue, services.databaseService, ERC20FacadeResultKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<Void>(initParams: getChainIdInitParams,
                                                                 completion: sendCompletion)
        
        // BlockData
        let getBlockDataInitParams = (registerQueue, services.databaseService, ERC20FacadeResultKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<Void>(initParams: getBlockDataInitParams,
                                                                     completion: sendCompletion)
        
        // Transaciton
        let transactionOperationInitParams = (queue: registerQueue,
                                              cryptoCore: cryptoCore,
                                              saveKey: ERC20FacadeResultKeys.transaction.rawValue,
                                              wif: wif,
                                              networkPrefix: network.echorandPrefix.rawValue,
                                              fromAccountKey: ERC20FacadeResultKeys.loadedAccount.rawValue,
                                              operationKey: ERC20FacadeResultKeys.operation.rawValue,
                                              chainIdKey: ERC20FacadeResultKeys.chainId.rawValue,
                                              blockDataKey: ERC20FacadeResultKeys.blockData.rawValue,
                                              feeKey: ERC20FacadeResultKeys.fee.rawValue,
                                              expirationOffset: transactionExpirationOffset)
        let bildTransactionOperation = GetTransactionQueueOperation<Void>(initParams: transactionOperationInitParams,
                                                                          completion: sendCompletion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (registerQueue,
                                                 services.networkBroadcastService,
                                                 EchoQueueMainKeys.operationId.rawValue,
                                                 ERC20FacadeResultKeys.transaction.rawValue)
        let sendTransactionOperation = SendTransactionQueueOperation(initParams: sendTransacionOperationInitParams,
                                                                     completion: sendCompletion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: registerQueue)
        
        registerQueue.addOperation(getAccountsOperation)
        registerQueue.addOperation(bildRegisterOperation)
        registerQueue.addOperation(getRequiredFeeOperation)
        registerQueue.addOperation(getChainIdOperation)
        registerQueue.addOperation(getBlockDataOperation)
        registerQueue.addOperation(bildTransactionOperation)
        registerQueue.addOperation(sendTransactionOperation)
        
        //Notice handler
        if let noticeHandler = confirmNoticeHandler {
            registerQueue.saveValue(noticeHandler, forKey: EchoQueueMainKeys.noticeHandler.rawValue)
            
            let waitingOperationParams = (
                registerQueue,
                EchoQueueMainKeys.notice.rawValue,
                EchoQueueMainKeys.noticeError.rawValue
            )
            let waitOperation = WaitQueueOperation(initParams: waitingOperationParams)
            
            let noticeHadleOperaitonParams = (
                registerQueue,
                EchoQueueMainKeys.notice.rawValue,
                EchoQueueMainKeys.noticeError.rawValue,
                EchoQueueMainKeys.noticeHandler.rawValue
            )
            let noticeHandleOperation = NoticeHandleQueueOperation(initParams: noticeHadleOperaitonParams)
            
            registerQueue.addOperation(waitOperation)
            registerQueue.addOperation(noticeHandleOperation)
        }
        
        registerQueue.addOperation(completionOperation)
    }
    // swiftlint:enable function_body_length
    
    // swiftlint:disable function_body_length
    public func withdrawERC20(nameOrId: String,
                              wif: String,
                              toEthAddress: String,
                              tokenId: String,
                              value: String,
                              assetForFee: String?,
                              sendCompletion: @escaping Completion<Void>,
                              confirmNoticeHandler: NoticeHandler?) {
        
        // if we don't hace assetForFee, we use asset.
        let assetForFee = assetForFee ?? Settings.defaultAsset
        
        // Validate asset id and token id
        do {
            let validator = IdentifierValidator()
            try validator.validateId(assetForFee, for: .asset)
            try validator.validateId(tokenId, for: .erc20Token)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<Void, ECHOError>(error: echoError)
            sendCompletion(result)
            return
        }
        
        // Validate Ethereum address
        let ethValidator = ETHAddressValidator(cryptoCore: cryptoCore)
        guard ethValidator.isValidETHAddress(toEthAddress) else {
            let result = Result<Void, ECHOError>(error: .invalidETHAddress)
            sendCompletion(result)
            return
        }
        
        let withdrawalQueue = ECHOQueue()
        addQueue(withdrawalQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(nameOrId, ERC20FacadeResultKeys.loadedAccount.rawValue)])
        let getAccountsOperationInitParams = (withdrawalQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<Void>(initParams: getAccountsOperationInitParams,
                                                                   completion: sendCompletion)
        
        let bildWithdrawOperation = createBildWithdrawOperation(withdrawalQueue, Asset(assetForFee), value,
                                                                toEthAddress, tokenId, sendCompletion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (withdrawalQueue,
                                                 services.databaseService,
                                                 Asset(assetForFee),
                                                 ERC20FacadeResultKeys.operation.rawValue,
                                                 ERC20FacadeResultKeys.fee.rawValue,
                                                 UInt(1))
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<Void>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: sendCompletion)
        
        // ChainId
        let getChainIdInitParams = (withdrawalQueue, services.databaseService, ERC20FacadeResultKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<Void>(initParams: getChainIdInitParams,
                                                                 completion: sendCompletion)
        
        // BlockData
        let getBlockDataInitParams = (withdrawalQueue, services.databaseService, ERC20FacadeResultKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<Void>(initParams: getBlockDataInitParams,
                                                                     completion: sendCompletion)
        
        // Transaciton
        let transactionOperationInitParams = (queue: withdrawalQueue,
                                              cryptoCore: cryptoCore,
                                              saveKey: ERC20FacadeResultKeys.transaction.rawValue,
                                              wif: wif,
                                              networkPrefix: network.echorandPrefix.rawValue,
                                              fromAccountKey: ERC20FacadeResultKeys.loadedAccount.rawValue,
                                              operationKey: ERC20FacadeResultKeys.operation.rawValue,
                                              chainIdKey: ERC20FacadeResultKeys.chainId.rawValue,
                                              blockDataKey: ERC20FacadeResultKeys.blockData.rawValue,
                                              feeKey: ERC20FacadeResultKeys.fee.rawValue,
                                              expirationOffset: transactionExpirationOffset)
        let bildTransactionOperation = GetTransactionQueueOperation<Void>(initParams: transactionOperationInitParams,
                                                                          completion: sendCompletion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (withdrawalQueue,
                                                 services.networkBroadcastService,
                                                 EchoQueueMainKeys.operationId.rawValue,
                                                 ERC20FacadeResultKeys.transaction.rawValue)
        let sendTransactionOperation = SendTransactionQueueOperation(initParams: sendTransacionOperationInitParams,
                                                                     completion: sendCompletion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: withdrawalQueue)
        
        withdrawalQueue.addOperation(getAccountsOperation)
        withdrawalQueue.addOperation(bildWithdrawOperation)
        withdrawalQueue.addOperation(getRequiredFeeOperation)
        withdrawalQueue.addOperation(getChainIdOperation)
        withdrawalQueue.addOperation(getBlockDataOperation)
        withdrawalQueue.addOperation(bildTransactionOperation)
        withdrawalQueue.addOperation(sendTransactionOperation)
        
        //Notice handler
        if let noticeHandler = confirmNoticeHandler {
            withdrawalQueue.saveValue(noticeHandler, forKey: EchoQueueMainKeys.noticeHandler.rawValue)
            
            let waitingOperationParams = (
                withdrawalQueue,
                EchoQueueMainKeys.notice.rawValue,
                EchoQueueMainKeys.noticeError.rawValue
            )
            let waitOperation = WaitQueueOperation(initParams: waitingOperationParams)
            
            let noticeHadleOperaitonParams = (
                withdrawalQueue,
                EchoQueueMainKeys.notice.rawValue,
                EchoQueueMainKeys.noticeError.rawValue,
                EchoQueueMainKeys.noticeHandler.rawValue
            )
            let noticeHandleOperation = NoticeHandleQueueOperation(initParams: noticeHadleOperaitonParams)
            
            withdrawalQueue.addOperation(waitOperation)
            withdrawalQueue.addOperation(noticeHandleOperation)
        }
        
        withdrawalQueue.addOperation(completionOperation)
    }
    // swiftlint:enable function_body_length
    
    fileprivate func createBildRegisterOperation(_ queue: ECHOQueue,
                                                 _ asset: Asset,
                                                 _ tokenAddress: String,
                                                 _ tokenName: String,
                                                 _ tokenSymbol: String,
                                                 _ tokenDecimals: UInt8,
                                                 _ completion: @escaping Completion<Void>) -> Operation {
        
        let bildRegisterOperation = BlockOperation()
        
        bildRegisterOperation.addExecutionBlock { [weak bildRegisterOperation, weak queue] in
            
            guard bildRegisterOperation?.isCancelled == false else { return }
            
            guard let account: Account = queue?.getValue(ERC20FacadeResultKeys.loadedAccount.rawValue) else { return }
            
            let fee = AssetAmount(amount: 0, asset: asset)
            let address = tokenAddress.replacingOccurrences(of: "0x", with: "")
            
            let operation = SidechainERC20RegisterTokenOperation(account: account,
                                                                 ethAddress: address,
                                                                 name: tokenName,
                                                                 symbol: tokenSymbol,
                                                                 decimals: tokenDecimals,
                                                                 fee: fee)
            
            queue?.saveValue(operation, forKey: ERC20FacadeResultKeys.operation.rawValue)
        }
        
        return bildRegisterOperation
    }
    
    fileprivate func createBildWithdrawOperation(_ queue: ECHOQueue,
                                                 _ asset: Asset,
                                                 _ value: String,
                                                 _ toEthAddress: String,
                                                 _ tokenId: String,
                                                 _ completion: @escaping Completion<Void>) -> Operation {
        
        let bildWithdrawOperation = BlockOperation()
        
        bildWithdrawOperation.addExecutionBlock { [weak bildWithdrawOperation, weak queue] in
            
            guard bildWithdrawOperation?.isCancelled == false else { return }
            
            guard let account: Account = queue?.getValue(ERC20FacadeResultKeys.loadedAccount.rawValue) else { return }
            
            let fee = AssetAmount(amount: 0, asset: asset)
            let address = toEthAddress.replacingOccurrences(of: "0x", with: "")
            let token = ERC20Token(id: tokenId)
            
            let withdrawOperation = SidechainERC20WithdrawTokenOperation(account: account,
                                                                         toEthAddress: address,
                                                                         token: token,
                                                                         value: value,
                                                                         fee: fee)
            
            queue?.saveValue(withdrawOperation, forKey: ERC20FacadeResultKeys.operation.rawValue)
        }
        
        return bildWithdrawOperation
    }
}
