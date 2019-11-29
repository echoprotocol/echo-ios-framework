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
final public class ERC20FacadeImp: ERC20Facade, ECHOQueueble {

    var queues: [String: ECHOQueue]
    let services: EthFacadeServices
    let network: ECHONetwork
    let cryptoCore: CryptoCoreComponent
    
    public init(services: EthFacadeServices,
                cryptoCore: CryptoCoreComponent,
                network: ECHONetwork,
                noticeDelegateHandler: NoticeEventDelegateHandler) {
        
        self.services = services
        self.network = network
        self.cryptoCore = cryptoCore
        self.queues = [String: ECHOQueue]()
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
        services.databaseService.getERC20Token(tokenAddress: address, completion: completion)
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
        case operationId
        case notice
        case noticeError
        case noticeHandler
    }
    
    // swiftlint:disable function_body_length
    public func registerERC20Token(nameOrId: String,
                                   wif: String,
                                   tokenAddress: String,
                                   tokenName: String,
                                   tokenSymbol: String,
                                   tokenDecimals: UInt8,
                                   assetForFee: String?,
                                   completion: @escaping Completion<Bool>,
                                   noticeHandler: NoticeHandler?) {
        
        // if we don't hace assetForFee, we use asset.
        let assetForFee = assetForFee ?? Settings.defaultAsset
        
        // Validate asset id
        do {
            let validator = IdentifierValidator()
            try validator.validateId(assetForFee, for: .asset)
        } catch let error {
            let echoError = (error as? ECHOError) ?? ECHOError.undefined
            let result = Result<Bool, ECHOError>(error: echoError)
            completion(result)
            return
        }
        
        // Validate Ethereum address
        let ethValidator = ETHAddressValidator(cryptoCore: cryptoCore)
        guard ethValidator.isValidETHAddress(tokenAddress) else {
            let result = Result<Bool, ECHOError>(error: .invalidETHAddress)
            completion(result)
            return
        }
        
        let registerQueue = ECHOQueue()
        addQueue(registerQueue)
        
        // Accounts
        let getAccountsNamesOrIdsWithKeys = GetAccountsNamesOrIdWithKeys([(nameOrId, ERC20FacadeResultKeys.loadedAccount.rawValue)])
        let getAccountsOperationInitParams = (registerQueue,
                                              services.databaseService,
                                              getAccountsNamesOrIdsWithKeys)
        let getAccountsOperation = GetAccountsQueueOperation<Bool>(initParams: getAccountsOperationInitParams,
                                                                   completion: completion)
        
        let bildRegisterOperation = createBildRegisterOperation(registerQueue, Asset(assetForFee), tokenAddress,
                                                                tokenName, tokenSymbol, tokenDecimals, completion)
        
        // RequiredFee
        let getRequiredFeeOperationInitParams = (registerQueue,
                                                 services.databaseService,
                                                 Asset(assetForFee),
                                                 ERC20FacadeResultKeys.operation.rawValue,
                                                 ERC20FacadeResultKeys.fee.rawValue,
                                                 UInt(1))
        let getRequiredFeeOperation = GetRequiredFeeQueueOperation<Bool>(initParams: getRequiredFeeOperationInitParams,
                                                                         completion: completion)
        
        // ChainId
        let getChainIdInitParams = (registerQueue, services.databaseService, ERC20FacadeResultKeys.chainId.rawValue)
        let getChainIdOperation = GetChainIdQueueOperation<Bool>(initParams: getChainIdInitParams,
                                                                 completion: completion)
        
        // BlockData
        let getBlockDataInitParams = (registerQueue, services.databaseService, ERC20FacadeResultKeys.blockData.rawValue)
        let getBlockDataOperation = GetBlockDataQueueOperation<Bool>(initParams: getBlockDataInitParams,
                                                                     completion: completion)
        
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
                                              feeKey: ERC20FacadeResultKeys.fee.rawValue)
        let bildTransactionOperation = GetTransactionQueueOperation<Bool>(initParams: transactionOperationInitParams,
                                                                          completion: completion)
        
        // Send transaction
        let sendTransacionOperationInitParams = (registerQueue,
                                                 services.networkBroadcastService,
                                                 ERC20FacadeResultKeys.operationId.rawValue,
                                                 ERC20FacadeResultKeys.transaction.rawValue)
        let sendTransactionOperation = SendTransactionQueueOperation(initParams: sendTransacionOperationInitParams,
                                                                     completion: completion)
        
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
        if let noticeHandler = noticeHandler {
            registerQueue.saveValue(noticeHandler, forKey: ERC20FacadeResultKeys.noticeHandler.rawValue)
            let waitOperation = createWaitingOperation(registerQueue)
            let noticeHandleOperation = createNoticeHandleOperation(registerQueue,
                                                                    ERC20FacadeResultKeys.noticeHandler.rawValue,
                                                                    ERC20FacadeResultKeys.notice.rawValue,
                                                                    ERC20FacadeResultKeys.noticeError.rawValue)
            registerQueue.addOperation(waitOperation)
            registerQueue.addOperation(noticeHandleOperation)
        }
        
        registerQueue.addOperation(completionOperation)
    }
    // swiftlint:enable function_body_length
    
    fileprivate func createBildRegisterOperation(_ queue: ECHOQueue,
                                                 _ asset: Asset,
                                                 _ tokenAddress: String,
                                                 _ tokenName: String,
                                                 _ tokenSymbol: String,
                                                 _ tokenDecimals: UInt8,
                                                 _ completion: @escaping Completion<Bool>) -> Operation {
        
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
    
    fileprivate func createNoticeHandleOperation(_ queue: ECHOQueue,
                                                 _ noticeHandlerKey: String,
                                                 _ noticeKey: String,
                                                 _ noticeErrorKey: String) -> Operation {
        
        let noticeOperation = BlockOperation()
        
        noticeOperation.addExecutionBlock { [weak noticeOperation, weak queue, weak self] in
            
            guard noticeOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let noticeHandler: NoticeHandler = queue?.getValue(noticeHandlerKey) else { return }
            
            if let notice: ECHONotification = queue?.getValue(noticeKey) {
                let result = Result<ECHONotification, ECHOError>(value: notice)
                noticeHandler(result)
                return
            }
            
            if let noticeError: ECHOError = queue?.getValue(noticeErrorKey) {
                let result = Result<ECHONotification, ECHOError>(error: noticeError)
                noticeHandler(result)
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
}

extension ERC20FacadeImp: NoticeEventDelegate {
    
    public func didReceiveNotification(notification: ECHONotification) {
        
        switch notification.params {
        case .array(let array):
            if let noticeOperationId = array.first as? Int {
                
                for queue in queues.values {
                    
                    if let queueTransferOperationId: Int = queue.getValue(ERC20FacadeResultKeys.operationId.rawValue),
                        queueTransferOperationId == noticeOperationId {
                        queue.saveValue(notification, forKey: ERC20FacadeResultKeys.notice.rawValue)
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
            queue.saveValue(ECHOError.connectionLost, forKey: ERC20FacadeResultKeys.noticeError.rawValue)
            queue.startNextOperation()
        }
    }
}
