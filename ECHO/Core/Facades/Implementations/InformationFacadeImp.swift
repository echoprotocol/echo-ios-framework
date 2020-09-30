//
//  InformationFacadeImp.swift
//  BitcoinKit
//
//  Created by Fedorenko Nikita on 19.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct InformationFacadeServices {
    var databaseService: DatabaseApiService
    var historyService: AccountHistoryApiService
    var registrationService: RegistrationApiService
}

/**
    Implementation of [InformationFacade](InformationFacade), [ECHOQueueble](ECHOQueueble)
 */
// swiftlint:disable file_length
// swiftlint:disable type_body_length
final public class InformationFacadeImp: InformationFacade, ECHOQueueble, NoticeEventDelegate {
    
    public var queues: [String: ECHOQueue]
    let services: InformationFacadeServices
    let network: ECHONetwork
    let cryptoCore: CryptoCoreComponent
    
    init(services: InformationFacadeServices,
         network: ECHONetwork,
         cryptoCore: CryptoCoreComponent,
         noticeDelegateHandler: NoticeEventDelegateHandler) {
        
        self.services = services
        self.network = network
        self.cryptoCore = cryptoCore
        self.queues = [String: ECHOQueue]()
        
        noticeDelegateHandler.delegate = self
    }
    
    public func getObjects<T>(type: T.Type,
                              objectsIds: [String],
                              completion: @escaping (Result<[T], ECHOError>) -> Void) where T: Decodable {
        
        services.databaseService.getObjects(type: type, objectsIds: objectsIds, completion: completion)
    }
    
    public func getBlock(blockNumber: Int, completion: @escaping Completion<Block>) {
        
        services.databaseService.getBlock(blockNumber: blockNumber, completion: completion)
    }
    
    private enum CreationAccountResultsKeys: String {
        case isReserved
        case account
        case task
        case nonce
    }
    
    public func registerAccount(
        name: String,
        wif: String,
        evmAddress: String?,
        sendCompletion: @escaping Completion<Void>,
        confirmNoticeHandler: NoticeHandler?
    ) {
        // Validate Ethereum address if exist
        if let evmAddress = evmAddress {
            let ethValidator = ETHAddressValidator(cryptoCore: cryptoCore)
            guard ethValidator.isValidETHAddress(evmAddress) else {
                let result = Result<Void, ECHOError>(error: .invalidETHAddress)
                sendCompletion(result)
                return
            }
        }
        
        let createAccountQueue = ECHOQueue()
        addQueue(createAccountQueue)
        
        // Get Account
        let getAccountsOperationInitParams = (createAccountQueue,
                                              services.databaseService,
                                              name)
        let getAccountsOperation = GetIsReservedAccountQueueOperation<Void>(initParams: getAccountsOperationInitParams,
                                                                          completion: sendCompletion)
        getAccountsOperation.defaultError = ECHOError.invalidCredentials
        
        // Create Account
        let requestTaskOperation = createRequestRegistrationTask(createAccountQueue,
                                                                 completion: sendCompletion)
        let powTaskOperation = createPoWTaskCalculatingOperation(createAccountQueue, completion: sendCompletion)
        let submitOperation = createSubmitRegistrationSolutionOperation(createAccountQueue,
                                                                        name: name,
                                                                        wif: wif,
                                                                        evmAddress: evmAddress,
                                                                        completion: sendCompletion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: createAccountQueue)
        
        createAccountQueue.addOperation(getAccountsOperation)
        createAccountQueue.addOperation(requestTaskOperation)
        createAccountQueue.addOperation(powTaskOperation)
        createAccountQueue.addOperation(submitOperation)

        //Notice handler
        if let noticeHandler = confirmNoticeHandler {
            createAccountQueue.saveValue(noticeHandler, forKey: EchoQueueMainKeys.noticeHandler.rawValue)
            
            let waitingOperationParams = (
                createAccountQueue,
                EchoQueueMainKeys.notice.rawValue,
                EchoQueueMainKeys.noticeError.rawValue
            )
            let waitOperation = WaitQueueOperation(initParams: waitingOperationParams)
            
            let noticeHadleOperaitonParams = (
                createAccountQueue,
                EchoQueueMainKeys.notice.rawValue,
                EchoQueueMainKeys.noticeError.rawValue,
                EchoQueueMainKeys.noticeHandler.rawValue
            )
            let noticeHandleOperation = NoticeHandleQueueOperation(initParams: noticeHadleOperaitonParams)
            
            createAccountQueue.addOperation(waitOperation)
            createAccountQueue.addOperation(noticeHandleOperation)
        }
        
        createAccountQueue.addOperation(completionOperation)
    }
    
    fileprivate func createRequestRegistrationTask(_ queue: ECHOQueue,
                                                   completion: @escaping Completion<Void>) -> Operation {
        
        let operation = BlockOperation()

        operation.addExecutionBlock { [weak operation, weak queue, weak self] in
            
            guard operation?.isCancelled == false else { return }
            guard let strongSelf = self else { return }
            
            if let _: Account = queue?.getValue(CreationAccountResultsKeys.account.rawValue) {
                queue?.cancelAllOperations()
                let result = Result<Void, ECHOError>(error: ECHOError.invalidCredentials)
                completion(result)
                return
            }
            
            strongSelf.services.registrationService.requestRegistrationTask { (result) in
                switch result {
                case .success(let task):
                    queue?.saveValue(task, forKey: CreationAccountResultsKeys.task.rawValue)
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<Void, ECHOError>(error: error)
                    completion(result)
                }

                queue?.startNextOperation()
            }
            
            queue?.waitStartNextOperation()
        }
        
        return operation
    }
    
    fileprivate func createPoWTaskCalculatingOperation(_ queue: ECHOQueue,
                                                       completion: @escaping Completion<Void>) -> Operation {
        
        let operation = BlockOperation()

        operation.addExecutionBlock { [weak operation, weak queue, weak self] in
            
            guard operation?.isCancelled == false else { return }
            guard let strongSelf = self else { return }
            guard let task: RegistrationTask = queue?.getValue(CreationAccountResultsKeys.task.rawValue) else { return }
            
            guard let blockIdData = Data(hex: task.blockId) else {
                queue?.cancelAllOperations()
                let result = Result<Void, ECHOError>(error: ECHOError.encodableMapping)
                completion(result)
                return
            }
            let randNumData = Data.fromUint64(task.randNum.uintValue)
            let constantData = blockIdData + randNumData
            var nonce: UInt = 0
            
            var lastCheckByteIndex = Int(task.difficulty / 8)
            let remainderOfTheDivision = task.difficulty % 8
            if remainderOfTheDivision > 0 {
                lastCheckByteIndex += 1
            }
            var offset = remainderOfTheDivision
            if offset > 0 {
                offset -= 1
            }
            let maxValueLastByte = UInt8(1) << offset
            
            while nonce < UInt.max {
                var isValid = true
                autoreleasepool {
                    let nonceData = Data.fromUint64(nonce)
                    let sha256Data = constantData + nonceData
                    let result = strongSelf.cryptoCore.sha256(sha256Data)
            
                    for index in 0..<lastCheckByteIndex {
                        let byte = result.bytes[index]
                        if index == lastCheckByteIndex - 1 {
                            if byte >= maxValueLastByte {
                                isValid = false
                                break
                            }
                        } else {
                            if byte != 0 {
                                isValid = false
                                break
                            }
                        }
                    }
                }
                
                if isValid {
                    break
                }
                
                nonce += 1
            }
            queue?.saveValue(nonce, forKey: CreationAccountResultsKeys.nonce.rawValue)
        }
        
        return operation
    }
    
    fileprivate func createSubmitRegistrationSolutionOperation(_ queue: ECHOQueue,
                                                               name: String,
                                                               wif: String,
                                                               evmAddress: String?,
                                                               completion: @escaping Completion<Void>) -> Operation {
        
        let operation = BlockOperation()

        operation.addExecutionBlock { [weak operation, weak queue, weak self] in
            
            guard operation?.isCancelled == false else { return }
            guard let strongSelf = self else { return }
            guard let task: RegistrationTask = queue?.getValue(CreationAccountResultsKeys.task.rawValue) else { return }
            guard let nonce: UInt = queue?.getValue(CreationAccountResultsKeys.nonce.rawValue) else { return }
            
            guard let keychain = ECHOKeychainEd25519(wif: wif, core: strongSelf.cryptoCore) else {
                queue?.cancelAllOperations()
                let result = Result<Void, ECHOError>(error: ECHOError.invalidWIF)
                completion(result)
                return
            }
            
            let key = strongSelf.network.echorandPrefix.rawValue + keychain.publicAddress()
            
            let regService = strongSelf.services.registrationService
            let operationID = regService.submitRegistrationSolution(name: name,
                                                                    activeKey: key,
                                                                    echorandKey: key,
                                                                    evmAddress: evmAddress,
                                                                    nonce: nonce,
                                                                    randNum: task.randNum.uintValue) { (result) in
                switch result {
                case .success(let value):
                    if value == false {
                        queue?.cancelAllOperations()
                        let result = Result<Void, ECHOError>(error: ECHOError.invalidCredentials)
                        completion(result)
                    } else {
                        let result = Result<Void, ECHOError>(value: ())
                        completion(result)
                    }
                    queue?.startNextOperation()
                    
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<Void, ECHOError>(error: error)
                    completion(result)
                }
            }
            
            queue?.saveValue(operationID, forKey: EchoQueueMainKeys.operationId.rawValue)
            queue?.waitStartNextOperation()
        }
        
        return operation
    }
    
    public func getAccount(nameOrID: String, completion: @escaping Completion<Account>) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrID], shoudSubscribe: false) { (result) in
            switch result {
            case .success(let userAccounts):
                
                guard let account = userAccounts[nameOrID] else {
                    let result = Result<Account, ECHOError>(error: ECHOError.resultNotFound)
                    completion(result)
                    return
                }
                
                let result = Result<Account, ECHOError>(value: account.account)
                completion(result)
            case .failure(let error):
                let result = Result<Account, ECHOError>(error: error)
                completion(result)
            }
        }
    }
    
    public func isAccountReserved(nameOrID: String, completion: @escaping Completion<Bool>) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrID], shoudSubscribe: false) { (result) in
            switch result {
            case .success(let accounts):
                let result = Result<Bool, ECHOError>(value: accounts.count > 0)
                completion(result)
            case .failure(_):
                let result = Result<Bool, ECHOError>(value: false)
                completion(result)
            }
        }
    }
    
    public func getBalance(nameOrID: String, asset: String?, completion: @escaping Completion<[AccountBalance]>) {
        
        services.databaseService.getFullAccount(nameOrIds: [nameOrID], shoudSubscribe: false) { (result) in
            switch result {
            case .success(let userAccounts):
                
                let balances: [AccountBalance]

                guard let account = userAccounts[nameOrID] else {
                    let result = Result<[AccountBalance], ECHOError>(error: ECHOError.resultNotFound)
                    completion(result)
                    return
                }
                
                if let asset = asset {
                    
                    // Validate asset id
                    do {
                        let validator = IdentifierValidator()
                        try validator.validateId(asset, for: .asset)
                    } catch let error {
                        let echoError = (error as? ECHOError) ?? ECHOError.undefined
                        let result = Result<[AccountBalance], ECHOError>(error: echoError)
                        completion(result)
                        return
                    }
                    
                    balances = account.balances.filter {$0.assetType == asset }
                } else {
                    balances =  account.balances
                }
                
                let result = Result<[AccountBalance], ECHOError>(value: balances)
                completion(result)
            case .failure(let error):
                let result = Result<[AccountBalance], ECHOError>(error: error)
                completion(result)
            }
        }
    }
    
    public func getGlobalProperties(completion: @escaping Completion<GlobalProperties>) {
        
        services.databaseService.getGlobalProperties(completion: completion)
    }
    
    // MARK: History
    private enum AccountHistoryResultsKeys: String {
        case account
        case historyItems
        case findedBlockNums
        case loadedBlocks
        case findedAccountIds
        case findedDepositsIds
        case findedWithdrawalsIds
        case findedERC20TokensIds
        case findedERC20DepositsIds
        case findedERC20WithdrawalsIds
        case loadedAccounts
        case loadedDeposits
        case loadedWithdrawals
        case loadedERC20Tokens
        case loadedERC20Deposits
        case loadedERC20Withdrawals
        case findedAssetIds
        case loadedAssets
    }
    
    public func getAccountHistroy(nameOrID: String, startId: String, stopId: String, limit: Int, completion: @escaping Completion<[HistoryItem]>) {
        
        let accountHistoryQueue = ECHOQueue()
        addQueue(accountHistoryQueue)
        
        // Account
        let getAccountNameOrIdsWithKey = GetAccountsNamesOrIdWithKeys([(nameOrID, AccountHistoryResultsKeys.account.rawValue)])
        let getAccountOperationInitParams = (accountHistoryQueue,
                                             services.databaseService,
                                             getAccountNameOrIdsWithKey)
        let getAccountOperation = GetAccountsQueueOperation<[HistoryItem]>(initParams: getAccountOperationInitParams,
                                                                   completion: completion)
        
        // History
        let getHistoryOperation = createGetHistoryOperation(accountHistoryQueue,
                                                            startId: startId, stopId: stopId, limit: limit,
                                                            completion: completion)
        
        // OtherData
        let getBlocksOperation = createGetBlocksOperation(accountHistoryQueue, completion)
        let getAccountsOperation = createGetAccountsOperation(accountHistoryQueue, completion)
        let getAssetsOperation = createGetAssetsOperation(accountHistoryQueue, completion)
        let getSidechainDepositsOperation = createGetSidechainDepositsOperation(accountHistoryQueue, completion)
        let getSidechainWithdrawsOperation = createGetSidechainWithdrawsOperation(accountHistoryQueue, completion)
        let getERC20TokensOperation = createGetSidechainERC20TokensOperation(accountHistoryQueue, completion)
        let getERC20DepositsOperation = createGetSidechainERC20DepositsOperation(accountHistoryQueue, completion)
        let getERC20WithdrawsOperation = createGetSidechainERC20WithdrawsOperation(accountHistoryQueue, completion)
        let mergeBlocksToHistoryOperation = createMergeBlocksInHistoryOperation(accountHistoryQueue, completion)
        let mergeAccountsToHistoryOperation = createMergeAccountsInHistoryOperation(accountHistoryQueue, completion)
        let mergeAssetsToHistoryOperation = createMergeAssetsInHistoryOperation(accountHistoryQueue, completion)
        let mergeSidechainDepositsToHistoryOperation = createMergeSidechainDepositsInHistoryOperation(accountHistoryQueue, completion)
        let mergeSidechainWithdrawInHistoryOperation = createMergeSidechainWithdrawsInHistoryOperation(accountHistoryQueue, completion)
        let mergeERC20TokensInHistoryOperation = createMergeSidechainERC20TokensInHistoryOperation(accountHistoryQueue, completion)
        let mergeERC20DepositsInHistoryOperation = createMergeSidechainERC20DepositsInHistoryOperation(accountHistoryQueue, completion)
        let mergeERC20WithdrawInHistoryOperation = createMergeSidechainERC20WithdrawsInHistoryOperation(accountHistoryQueue, completion)
        
        // Completion
        let historyCompletionOperation = createHistoryComletionOperation(accountHistoryQueue, completion)
        let completionOperation = createCompletionOperation(queue: accountHistoryQueue)
        
        accountHistoryQueue.addOperation(getAccountOperation)
        accountHistoryQueue.addOperation(getHistoryOperation)
        accountHistoryQueue.addOperation(getBlocksOperation)
        accountHistoryQueue.addOperation(getAccountsOperation)
        accountHistoryQueue.addOperation(getAssetsOperation)
        accountHistoryQueue.addOperation(getSidechainDepositsOperation)
        accountHistoryQueue.addOperation(getERC20DepositsOperation)
        accountHistoryQueue.addOperation(getSidechainWithdrawsOperation)
        accountHistoryQueue.addOperation(getERC20TokensOperation)
        accountHistoryQueue.addOperation(getERC20WithdrawsOperation)
        accountHistoryQueue.addOperation(mergeBlocksToHistoryOperation)
        accountHistoryQueue.addOperation(mergeAccountsToHistoryOperation)
        accountHistoryQueue.addOperation(mergeAssetsToHistoryOperation)
        accountHistoryQueue.addOperation(mergeSidechainDepositsToHistoryOperation)
        accountHistoryQueue.addOperation(mergeSidechainWithdrawInHistoryOperation)
        accountHistoryQueue.addOperation(mergeERC20TokensInHistoryOperation)
        accountHistoryQueue.addOperation(mergeERC20DepositsInHistoryOperation)
        accountHistoryQueue.addOperation(mergeERC20WithdrawInHistoryOperation)
        accountHistoryQueue.addOperation(historyCompletionOperation)
    
        accountHistoryQueue.addOperation(completionOperation)
    }
    
    fileprivate func createGetHistoryOperation(_ queue: ECHOQueue,
                                               startId: String, stopId: String, limit: Int,
                                               completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let getHistoryOperation = BlockOperation()
        
        getHistoryOperation.addExecutionBlock { [weak getHistoryOperation, weak self, weak queue] in
            
            guard getHistoryOperation?.isCancelled == false else { return }
            guard let account: Account = queue?.getValue(AccountHistoryResultsKeys.account.rawValue) else { return }
            
            self?.services.historyService.getAccountHistory(id: account.id, startId: startId, stopId: stopId, limit: limit, completion: { (result) in
                switch result {
                case .success(let historyItems):
                    queue?.saveValue(historyItems, forKey: AccountHistoryResultsKeys.historyItems.rawValue)
                    if let findedData = self?.findDataToLoadFromHistoryItems(historyItems) {
                        queue?.saveValue(findedData.blockNums, forKey: AccountHistoryResultsKeys.findedBlockNums.rawValue)
                        queue?.saveValue(findedData.accountIds, forKey: AccountHistoryResultsKeys.findedAccountIds.rawValue)
                        queue?.saveValue(findedData.assetIds, forKey: AccountHistoryResultsKeys.findedAssetIds.rawValue)
                        queue?.saveValue(findedData.depositsIds, forKey: AccountHistoryResultsKeys.findedDepositsIds.rawValue)
                        queue?.saveValue(findedData.withdrawsIds, forKey: AccountHistoryResultsKeys.findedWithdrawalsIds.rawValue)
                        queue?.saveValue(findedData.erc20TokensIds, forKey: AccountHistoryResultsKeys.findedERC20TokensIds.rawValue)
                        queue?.saveValue(findedData.erc20DepositsIds, forKey: AccountHistoryResultsKeys.findedERC20DepositsIds.rawValue)
                        queue?.saveValue(findedData.erc20WithdrawsIds, forKey: AccountHistoryResultsKeys.findedERC20WithdrawalsIds.rawValue)
                    }
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<[HistoryItem], ECHOError>(error: error)
                    completion(result)
                }
                
                queue?.startNextOperation()
            })
            
            queue?.waitStartNextOperation()
        }
        
        return getHistoryOperation
    }
    
    fileprivate func createGetBlocksOperation(_ queue: ECHOQueue, _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let getBlockOperation = BlockOperation()
        
        getBlockOperation.addExecutionBlock { [weak getBlockOperation, weak self, weak queue] in
            
            guard let findedBlockNums: Set<Int> = queue?.getValue(AccountHistoryResultsKeys.findedBlockNums.rawValue) else { return }
            let blockNumberCounts = findedBlockNums.count
            
            for _ in 0..<blockNumberCounts {
                
                guard getBlockOperation?.isCancelled == false else { return }
                guard var findedBlockNums: Set<Int> = queue?.getValue(AccountHistoryResultsKeys.findedBlockNums.rawValue) else { return }
                guard let blockNumber: Int = findedBlockNums.first else { return }
                
                self?.services.databaseService.getBlock(blockNumber: blockNumber, completion: { (result) in
                    switch result {
                    case .success(let block):
                        findedBlockNums.removeFirst()
                        queue?.saveValue(findedBlockNums, forKey: AccountHistoryResultsKeys.findedBlockNums.rawValue)
                        
                        if var loadedBlocks: [Int: Block] = queue?.getValue(AccountHistoryResultsKeys.loadedBlocks.rawValue) {
                            loadedBlocks[blockNumber] = block
                            queue?.saveValue(loadedBlocks, forKey: AccountHistoryResultsKeys.loadedBlocks.rawValue)
                        } else {
                            let loadedBlocks = [blockNumber: block]
                            queue?.saveValue(loadedBlocks, forKey: AccountHistoryResultsKeys.loadedBlocks.rawValue)
                        }
                        
                    case .failure(let error):
                        queue?.cancelAllOperations()
                        let result = Result<[HistoryItem], ECHOError>(error: error)
                        completion(result)
                    }
                    
                    queue?.startNextOperation()
                })
                
                queue?.waitStartNextOperation()
            }
        }
        
        return getBlockOperation
    }
    
    fileprivate func createGetAssetsOperation(_ queue: ECHOQueue, _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let getAssetsOperation = BlockOperation()
        
        getAssetsOperation.addExecutionBlock { [weak getAssetsOperation, weak queue, weak self] in
            
            guard getAssetsOperation?.isCancelled == false else { return }
            guard let assetsIds: Set<String> = queue?.getValue(AccountHistoryResultsKeys.findedAssetIds.rawValue) else { return }
            
            let assetsArray = assetsIds.map { $0 }
            
            self?.services.databaseService.getAssets(assetIds: assetsArray, completion: { (result) in
                switch result {
                case .success(let assets):
                    queue?.saveValue(assets, forKey: AccountHistoryResultsKeys.loadedAssets.rawValue)
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<[HistoryItem], ECHOError>(error: error)
                    completion(result)
                }
                queue?.startNextOperation()
            })
            
            queue?.waitStartNextOperation()
        }
        
        return getAssetsOperation
    }
    
    fileprivate func createGetAccountsOperation(_ queue: ECHOQueue,
                                                _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let getAccountsOperation = BlockOperation()
        
        getAccountsOperation.addExecutionBlock { [weak getAccountsOperation, weak queue, weak self] in
            
            guard getAccountsOperation?.isCancelled == false else { return }
            guard let accountsId: Set<String> = queue?.getValue(AccountHistoryResultsKeys.findedAccountIds.rawValue) else { return }
            
            let accountsIdArray = accountsId.map { $0 }
            
            self?.services.databaseService.getFullAccount(nameOrIds: accountsIdArray, shoudSubscribe: false, completion: { (result) in
                switch result {
                case .success(let accounts):
                    queue?.saveValue(accounts, forKey: AccountHistoryResultsKeys.loadedAccounts.rawValue)
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<[HistoryItem], ECHOError>(error: error)
                    completion(result)
                }
                
                queue?.startNextOperation()
            })
            
            queue?.waitStartNextOperation()
        }
        
        return getAccountsOperation
    }
    
    fileprivate func createGetSidechainDepositsOperation(_ queue: ECHOQueue,
                                                         _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let getSidechainDepositsOperation = BlockOperation()
        
        getSidechainDepositsOperation.addExecutionBlock { [weak getSidechainDepositsOperation, weak queue, weak self] in
            
            guard getSidechainDepositsOperation?.isCancelled == false else { return }
            guard let depositsIds: Set<String> = queue?.getValue(AccountHistoryResultsKeys.findedDepositsIds.rawValue) else { return }
            
            let depositsIdsArray = depositsIds.map { $0 }
            
            self?.services.databaseService.getObjects(type: SidechainDepositEnum.self,
                                                      objectsIds: depositsIdsArray,
                                                      completion: { (result) in
                
                switch result {
                case .success(let deposits):
                    queue?.saveValue(deposits, forKey: AccountHistoryResultsKeys.loadedDeposits.rawValue)
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<[HistoryItem], ECHOError>(error: error)
                    completion(result)
                }
                
                queue?.startNextOperation()
            })
            
            queue?.waitStartNextOperation()
        }
        
        return getSidechainDepositsOperation
    }
    
    fileprivate func createGetSidechainWithdrawsOperation(_ queue: ECHOQueue, _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let getSidechainWithdrawsOperation = BlockOperation()
        
        getSidechainWithdrawsOperation.addExecutionBlock { [weak getSidechainWithdrawsOperation, weak queue, weak self] in
            
            guard getSidechainWithdrawsOperation?.isCancelled == false else { return }
            guard let withdrawsIds: Set<String> = queue?.getValue(AccountHistoryResultsKeys.findedWithdrawalsIds.rawValue) else { return }
            
            let withdrawsIdsArray = withdrawsIds.map { $0 }
            
            self?.services.databaseService.getObjects(type: SidechainWithdrawalEnum.self,
                                                      objectsIds: withdrawsIdsArray,
                                                      completion: { (result) in
                                                        
                switch result {
                case .success(let deposits):
                    queue?.saveValue(deposits, forKey: AccountHistoryResultsKeys.loadedWithdrawals.rawValue)
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<[HistoryItem], ECHOError>(error: error)
                    completion(result)
                }
                
                queue?.startNextOperation()
            })
            
            queue?.waitStartNextOperation()
        }
        
        return getSidechainWithdrawsOperation
    }
    
    fileprivate func createGetSidechainERC20TokensOperation(_ queue: ECHOQueue,
                                                            _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let getSidechainERC20TokensOperation = BlockOperation()
        
        getSidechainERC20TokensOperation.addExecutionBlock { [weak getSidechainERC20TokensOperation, weak queue, weak self] in
            
            guard getSidechainERC20TokensOperation?.isCancelled == false else { return }
            guard let erc20TokensIds: Set<String> = queue?.getValue(AccountHistoryResultsKeys.findedERC20TokensIds.rawValue) else { return }
            
            let tokensIdsArray = erc20TokensIds.map { $0 }
            
            self?.services.databaseService.getObjects(type: ERC20Token.self,
                                                      objectsIds: tokensIdsArray,
                                                      completion: { (result) in
                                                        
                switch result {
                case .success(let tokens):
                    queue?.saveValue(tokens, forKey: AccountHistoryResultsKeys.loadedERC20Tokens.rawValue)
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<[HistoryItem], ECHOError>(error: error)
                    completion(result)
                }
                
                queue?.startNextOperation()
            })
            
            queue?.waitStartNextOperation()
        }
        
        return getSidechainERC20TokensOperation
    }
    
    fileprivate func createGetSidechainERC20DepositsOperation(_ queue: ECHOQueue, _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
    
        let getERC20DepositsOperation = BlockOperation()
        
        getERC20DepositsOperation.addExecutionBlock { [weak getERC20DepositsOperation, weak queue, weak self] in
            
            guard getERC20DepositsOperation?.isCancelled == false else { return }
            guard let erc20DepositsIds: Set<String> = queue?.getValue(AccountHistoryResultsKeys.findedERC20DepositsIds.rawValue) else { return }
            
            let depositsIdsArray = erc20DepositsIds.map { $0 }
            
            self?.services.databaseService.getObjects(type: ERC20Deposit.self,
                                                      objectsIds: depositsIdsArray,
                                                      completion: { (result) in
                                                        
                switch result {
                case .success(let deposits):
                    queue?.saveValue(deposits, forKey: AccountHistoryResultsKeys.loadedERC20Deposits.rawValue)
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<[HistoryItem], ECHOError>(error: error)
                    completion(result)
                }
                
                queue?.startNextOperation()
            })
            
            queue?.waitStartNextOperation()
        }
        
        return getERC20DepositsOperation
    }
    
    fileprivate func createGetSidechainERC20WithdrawsOperation(_ queue: ECHOQueue, _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let getERC20WithdrawsOperation = BlockOperation()
        
        getERC20WithdrawsOperation.addExecutionBlock { [weak getERC20WithdrawsOperation, weak queue, weak self] in
            
            guard getERC20WithdrawsOperation?.isCancelled == false else { return }
            guard let erc20WithdrawsIds: Set<String> = queue?.getValue(AccountHistoryResultsKeys.findedERC20WithdrawalsIds.rawValue) else { return }
            
            let withdrawsIdsArray = erc20WithdrawsIds.map { $0 }
            
            self?.services.databaseService.getObjects(type: ERC20Withdrawal.self,
                                                      objectsIds: withdrawsIdsArray,
                                                      completion: { (result) in
                                                        
                switch result {
                case .success(let withdrawals):
                    queue?.saveValue(withdrawals, forKey: AccountHistoryResultsKeys.loadedERC20Withdrawals.rawValue)
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<[HistoryItem], ECHOError>(error: error)
                    completion(result)
                }
                
                queue?.startNextOperation()
            })
            
            queue?.waitStartNextOperation()
        }
        
        return getERC20WithdrawsOperation
    }
    
    fileprivate func createMergeBlocksInHistoryOperation(_ queue: ECHOQueue,
                                                         _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let mergeBlocksInHistoryOperation = BlockOperation()
        
        mergeBlocksInHistoryOperation.addExecutionBlock { [weak mergeBlocksInHistoryOperation, weak queue] in
            
            guard mergeBlocksInHistoryOperation?.isCancelled == false else { return }
            guard var history: [HistoryItem] = queue?.getValue(AccountHistoryResultsKeys.historyItems.rawValue) else { return }
            guard let blocks: [Int: Block] = queue?.getValue(AccountHistoryResultsKeys.loadedBlocks.rawValue) else { return }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = Settings.defaultDateFormat
            dateFormatter.locale = Locale(identifier: Settings.localeIdentifier)
            
            for index in 0..<history.count {
                
                var historyItem = history[index]
                
                guard let timestampString = blocks[historyItem.blockNum]?.timestamp else {
                    continue
                }
                
                let timestamp = dateFormatter.date(from: timestampString)
                historyItem.timestamp = timestamp
                history[index] = historyItem
            }
            
            queue?.saveValue(history, forKey: AccountHistoryResultsKeys.historyItems.rawValue)
        }
        
        return mergeBlocksInHistoryOperation
    }
    
    // swiftlint:disable function_body_length
    fileprivate func createMergeAccountsInHistoryOperation(_ queue: ECHOQueue,
                                                           _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let mergeAccountsInHistoryOperation = BlockOperation()
        
        mergeAccountsInHistoryOperation.addExecutionBlock { [weak mergeAccountsInHistoryOperation, weak self, weak queue] in
            
            guard mergeAccountsInHistoryOperation?.isCancelled == false else { return }
            guard var history: [HistoryItem] = queue?.getValue(AccountHistoryResultsKeys.historyItems.rawValue) else { return }
            guard let accounts: [String: UserAccount] = queue?.getValue(AccountHistoryResultsKeys.loadedAccounts.rawValue) else { return }
            
            for index in 0..<history.count {
                
                var historyItem = history[index]
                guard let operation = historyItem.operation else { continue }
            
                if var operation = operation as? TransferOperation {
                    let fromAccount = self?.findAccountIn(accounts, accountId: operation.fromAccount.id)
                    let toAccount = self?.findAccountIn(accounts, accountId: operation.toAccount.id)
                    operation.changeAccounts(from: fromAccount, toAccount: toAccount)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? AccountUpdateOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.account.id)
                    operation.changeAccount(account)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? CreateAssetOperation {
                    if let id = operation.asset.issuer?.id {
                        let issuer = self?.findAccountIn(accounts, accountId: id)
                        operation.changeIssuer(issuer)
                        historyItem.operation = operation
                    }
                }
                
                if var operation = operation as? IssueAssetOperation {
                    let issuer = self?.findAccountIn(accounts, accountId: operation.issuer.id)
                    let issuerToAccount = self?.findAccountIn(accounts, accountId: operation.issueToAccount.id)
                    operation.changeAccounts(issuer: issuer, issueToAccount: issuerToAccount)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? AccountCreateOperation {
                    let registrar = self?.findAccountIn(accounts, accountId: operation.registrar.id)
                    operation.changeAccounts(registrar: registrar)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? CallContractOperation {
                    let registrar = self?.findAccountIn(accounts, accountId: operation.registrar.id)
                    operation.changeRegistrar(registrar)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? CreateContractOperation {
                    let registrar = self?.findAccountIn(accounts, accountId: operation.registrar.id)
                    operation.changeRegistrar(registrar)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? BlockRewardOperation {
                    let receiver = self?.findAccountIn(accounts, accountId: operation.receiver.id)
                    operation.changeReceiver(account: receiver)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? ContractFundPoolOperation {
                    let sender = self?.findAccountIn(accounts, accountId: operation.sender.id)
                    operation.changeSender(account: sender)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainETHCreateAddressOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.account.id)
                    operation.changeAccount(account: account)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainETHDepositOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.account.id)
                    let committeeMember = self?.findAccountIn(accounts, accountId: operation.committeeMember.id)
                    operation.changeAccounts(committeeMember: committeeMember, account: account)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainETHWithdrawOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.account.id)
                    operation.changeAccount(account: account)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainETHApproveAddressOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.account.id)
                    let committeeMember = self?.findAccountIn(accounts, accountId: operation.committeeMember.id)
                    operation.changeAccounts(committeeMember: committeeMember, account: account)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainIssueOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.account.id)
                    operation.changeAccount(account: account)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainBurnOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.account.id)
                    operation.changeAccount(account: account)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainBTCCreateAddressOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.account.id)
                    operation.changeAccount(account: account)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainBTCCreateIntermediateDepositOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.account.id)
                    let committeeMember = self?.findAccountIn(accounts, accountId: operation.committeeMember.id)
                    operation.changeAccounts(committeeMember: committeeMember, account: account)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainBTCWithdrawOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.account.id)
                    operation.changeAccount(account: account)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainERC20RegisterTokenOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.account.id)
                    operation.changeAccount(account: account)
                    historyItem.operation = operation
                }

                if var operation = operation as? SidechainERC20DepositTokenOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.account.id)
                    let committeeMember = self?.findAccountIn(accounts, accountId: operation.committeeMember.id)
                    operation.changeAccounts(account: account, committeeMember: committeeMember)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainERC20WithdrawTokenOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.account.id)
                    operation.changeAccount(account: account)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainERC20IssueOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.account.id)
                    operation.changeAccount(account: account)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainERC20BurnOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.account.id)
                    operation.changeAccount(account: account)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? BalanceClaimOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.depositToAccount.id)
                    operation.changeAccount(account: account)
                    historyItem.operation = operation
                    print(operation)
                }
                
                history[index] = historyItem
            }
            
            queue?.saveValue(history, forKey: AccountHistoryResultsKeys.historyItems.rawValue)
        }
        
        return mergeAccountsInHistoryOperation
    }
    // swiftlint:enable function_body_length
    
    fileprivate func createMergeSidechainDepositsInHistoryOperation(_ queue: ECHOQueue,
                                                                    _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let mergeSidechainDepositsInHistoryOperation = BlockOperation()
        
        mergeSidechainDepositsInHistoryOperation.addExecutionBlock { [weak mergeSidechainDepositsInHistoryOperation, weak self, weak queue] in
            
            guard mergeSidechainDepositsInHistoryOperation?.isCancelled == false else { return }
            guard var history: [HistoryItem] = queue?.getValue(AccountHistoryResultsKeys.historyItems.rawValue) else { return }
            guard let deposits: [SidechainDepositEnum] = queue?.getValue(AccountHistoryResultsKeys.loadedDeposits.rawValue) else { return }
            
            for index in 0..<history.count {
                
                var historyItem = history[index]
                
                guard let operation = historyItem.operation else { continue }
                
                if var operation = operation as? SidechainIssueOperation {
                    let deposit = self?.findSidechainDepositIn(deposits, depositId: operation.depositId)
                    operation.deposit = deposit
                    historyItem.operation = operation
                }
                
                history[index] = historyItem
            }
            
            queue?.saveValue(history, forKey: AccountHistoryResultsKeys.historyItems.rawValue)
        }
        
        return mergeSidechainDepositsInHistoryOperation
    }
    
    fileprivate func createMergeSidechainWithdrawsInHistoryOperation(_ queue: ECHOQueue,
                                                                     _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let mergeSidechainWithdrawsOperation = BlockOperation()
        
        mergeSidechainWithdrawsOperation.addExecutionBlock { [weak mergeSidechainWithdrawsOperation, weak self, weak queue] in
            
            guard mergeSidechainWithdrawsOperation?.isCancelled == false else { return }
            guard var history: [HistoryItem] = queue?.getValue(AccountHistoryResultsKeys.historyItems.rawValue) else { return }
            guard let withdraws: [SidechainWithdrawalEnum] = queue?.getValue(AccountHistoryResultsKeys.loadedWithdrawals.rawValue) else { return }
            
            for index in 0..<history.count {
                
                var historyItem = history[index]
                
                guard let operation = historyItem.operation else { continue }
                
                if var operation = operation as? SidechainBurnOperation {
                    let withdraw = self?.findSidechainWithdrawsIn(withdraws, withdrawId: operation.withdrawId)
                    operation.withdraw = withdraw
                    historyItem.operation = operation
                }
                
                history[index] = historyItem
            }
            
            queue?.saveValue(history, forKey: AccountHistoryResultsKeys.historyItems.rawValue)
        }
        
        return mergeSidechainWithdrawsOperation
    }
    
    fileprivate func createMergeSidechainERC20TokensInHistoryOperation(_ queue: ECHOQueue,
                                                                       _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let mergeSidechainERC20TokensOperation = BlockOperation()
        
        mergeSidechainERC20TokensOperation.addExecutionBlock { [weak mergeSidechainERC20TokensOperation, weak self, weak queue] in
            
            guard mergeSidechainERC20TokensOperation?.isCancelled == false else { return }
            guard var history: [HistoryItem] = queue?.getValue(AccountHistoryResultsKeys.historyItems.rawValue) else { return }
            guard let tokens: [ERC20Token] = queue?.getValue(AccountHistoryResultsKeys.loadedERC20Tokens.rawValue) else { return }
            
            for index in 0..<history.count {
                
                var historyItem = history[index]
                
                guard let operation = historyItem.operation else { continue }
                
                if var operation = operation as? SidechainERC20IssueOperation {
                    let token = self?.findSidechainERC20TokenIn(tokens, tokenId: operation.token.id)
                    operation.changeToken(token: token)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainERC20BurnOperation {
                    let token = self?.findSidechainERC20TokenIn(tokens, tokenId: operation.token.id)
                    operation.changeToken(token: token)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainERC20WithdrawTokenOperation {
                    let token = self?.findSidechainERC20TokenIn(tokens, tokenId: operation.token.id)
                    operation.changeToken(token: token)
                    historyItem.operation = operation
                }
                
                history[index] = historyItem
            }
            
            queue?.saveValue(history, forKey: AccountHistoryResultsKeys.historyItems.rawValue)
        }
        
        return mergeSidechainERC20TokensOperation
    }
    
    fileprivate func createMergeSidechainERC20DepositsInHistoryOperation(_ queue: ECHOQueue,
                                                                         _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let mergeSidechainERC20DepositsOperation = BlockOperation()
        
        mergeSidechainERC20DepositsOperation.addExecutionBlock { [weak mergeSidechainERC20DepositsOperation, weak self, weak queue] in
            
            guard mergeSidechainERC20DepositsOperation?.isCancelled == false else { return }
            guard var history: [HistoryItem] = queue?.getValue(AccountHistoryResultsKeys.historyItems.rawValue) else { return }
            guard let deposits: [ERC20Deposit] = queue?.getValue(AccountHistoryResultsKeys.loadedERC20Deposits.rawValue) else { return }
            
            for index in 0..<history.count {
                
                var historyItem = history[index]
                
                guard let operation = historyItem.operation else { continue }
                
                if var operation = operation as? SidechainERC20IssueOperation {
                    let deposit = self?.findSidechainERC20DepositIn(deposits, depositId: operation.depositId)
                    operation.deposit = deposit
                    historyItem.operation = operation
                }
                
                history[index] = historyItem
            }
            
            queue?.saveValue(history, forKey: AccountHistoryResultsKeys.historyItems.rawValue)
        }
        
        return mergeSidechainERC20DepositsOperation
    }
    
    fileprivate func createMergeSidechainERC20WithdrawsInHistoryOperation(_ queue: ECHOQueue,
                                                                          _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let mergeSidechainERC20WithdrawsOperation = BlockOperation()
        
        mergeSidechainERC20WithdrawsOperation.addExecutionBlock { [weak mergeSidechainERC20WithdrawsOperation, weak self, weak queue] in
            
            guard mergeSidechainERC20WithdrawsOperation?.isCancelled == false else { return }
            guard var history: [HistoryItem] = queue?.getValue(AccountHistoryResultsKeys.historyItems.rawValue) else { return }
            guard let withdraws: [ERC20Withdrawal] = queue?.getValue(AccountHistoryResultsKeys.loadedERC20Withdrawals.rawValue) else { return }
            
            for index in 0..<history.count {
                
                var historyItem = history[index]
                
                guard let operation = historyItem.operation else { continue }
                
                if var operation = operation as? SidechainERC20BurnOperation {
                    let withdraw = self?.findSidechainERC20WithdrawIn(withdraws, withdrawId: operation.withdrawId)
                    operation.withdraw = withdraw
                    historyItem.operation = operation
                }
                
                history[index] = historyItem
            }
            
            queue?.saveValue(history, forKey: AccountHistoryResultsKeys.historyItems.rawValue)
        }
        
        return mergeSidechainERC20WithdrawsOperation
    }
    
    // swiftlint:disable function_body_length
    fileprivate func createMergeAssetsInHistoryOperation(_ queue: ECHOQueue, _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let mergeAssetsInHistoryOperation = BlockOperation()
        
        mergeAssetsInHistoryOperation.addExecutionBlock { [weak mergeAssetsInHistoryOperation, weak self, weak queue] in
            
            guard mergeAssetsInHistoryOperation?.isCancelled == false else { return }
            guard var history: [HistoryItem] = queue?.getValue(AccountHistoryResultsKeys.historyItems.rawValue) else { return }
            guard let assets: [Asset] = queue?.getValue(AccountHistoryResultsKeys.loadedAssets.rawValue) else { return }
            
            for index in 0..<history.count {
                
                var historyItem = history[index]
                guard let operation = historyItem.operation else { continue }
                
                if var operation = operation as? TransferOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    let transferAsset = self?.findAssetsIn(assets, assetId: operation.transferAmount.asset.id)
                    operation.changeAssets(feeAsset: feeAsset, transferAmount: transferAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? CallContractOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    let asset = self?.findAssetsIn(assets, assetId: operation.value.asset.id)
                    operation.changeAssets(feeAsset: feeAsset, asset: asset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? CreateContractOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    let asset = self?.findAssetsIn(assets, assetId: operation.value.asset.id)
                    var supportedAsset: Asset?
                    if let supportedAssetId = operation.supportedAsset.object?.id {
                        supportedAsset = self?.findAssetsIn(assets, assetId: supportedAssetId)
                    }
                    operation.changeAssets(feeAsset: feeAsset, asset: asset, supportedAsset: supportedAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? AccountCreateOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    operation.changeAssets(feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? CreateAssetOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    let asset = self?.findAssetsIn(assets, assetId: operation.asset.id)
                    operation.changeAssets(feeAsset: feeAsset, asset: asset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? AccountUpdateOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    operation.changeAssets(feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? CreateAssetOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    
                    var asset: Asset?
                    
                    if let assetId = history[index].result[safe: 1] as? String {
                        asset = self?.findAssetsIn(assets, assetId: assetId)
                    }
                    operation.changeAssets(feeAsset: feeAsset, asset: asset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? IssueAssetOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    let assetToIssue = self?.findAssetsIn(assets, assetId: operation.assetToIssue.asset.id)
                    operation.changeAssets(feeAsset: feeAsset, assetToIssue: assetToIssue)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? ContractInternalCallOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    let valueAsset = self?.findAssetsIn(assets, assetId: operation.value.asset.id)
                    operation.changeAssets(valueAsset: valueAsset, feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? BlockRewardOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    operation.changeAssets(feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? ContractFundPoolOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    let valueAsset = self?.findAssetsIn(assets, assetId: operation.value.asset.id)
                    operation.changeAssets(valueAsset: valueAsset, feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainETHCreateAddressOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    operation.changeAssets(feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainETHDepositOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    operation.changeAssets(feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainETHWithdrawOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    operation.changeAssets(feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainETHApproveAddressOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    operation.changeAssets(feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainIssueOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    let valueAsset = self?.findAssetsIn(assets, assetId: operation.value.asset.id)
                    operation.changeAssets(valueAsset: valueAsset, feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainBurnOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    let valueAsset = self?.findAssetsIn(assets, assetId: operation.value.asset.id)
                    operation.changeAssets(valueAsset: valueAsset, feeAsset: feeAsset)
                    historyItem.operation = operation
                }

                if var operation = operation as? SidechainBTCCreateAddressOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    operation.changeAssets(feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainBTCCreateIntermediateDepositOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    operation.changeAssets(feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainBTCWithdrawOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    operation.changeAssets(feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainERC20RegisterTokenOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    operation.changeAssets(feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainERC20DepositTokenOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    operation.changeAssets(feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainERC20WithdrawTokenOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    operation.changeAssets(feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainERC20IssueOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    operation.changeAssets(feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainERC20BurnOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    operation.changeAssets(feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                history[index] = historyItem
            }
            
            queue?.saveValue(history, forKey: AccountHistoryResultsKeys.historyItems.rawValue)
        }
        
        return mergeAssetsInHistoryOperation
    }
    // swiftlint:enable function_body_length
    
    fileprivate func createHistoryComletionOperation(_ queue: ECHOQueue, _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let historyComletionOperation = BlockOperation()
        
        historyComletionOperation.addExecutionBlock { [weak historyComletionOperation, weak queue] in
            
            guard historyComletionOperation?.isCancelled == false else { return }
            guard let history: [HistoryItem] = queue?.getValue(AccountHistoryResultsKeys.historyItems.rawValue) else { return }
            
            let result = Result<[HistoryItem], ECHOError>(value: history)
            completion(result)
        }
        
        return historyComletionOperation
    }
    
    fileprivate func findAccountIn(_ dict: [String: UserAccount], accountId: String) -> Account? {
        
        return dict[accountId]?.account
    }
    
    fileprivate func findAssetsIn(_ array: [Asset], assetId: String) -> Asset? {
        
        return array.first(where: {$0.id == assetId})
    }
    
    fileprivate func findSidechainDepositIn(_ array: [SidechainDepositEnum], depositId: String) -> SidechainDepositEnum? {
        
        return array.first(where: {
            switch $0 {
            case .btc(let deposit):
                return deposit.id == depositId
            case .eth(let deposit):
                return deposit.id == depositId
            }
        })
    }
    
    fileprivate func findSidechainWithdrawsIn(_ array: [SidechainWithdrawalEnum], withdrawId: String) -> SidechainWithdrawalEnum? {
        
        return array.first(where: {
            switch $0 {
            case .btc(let withdraw):
                return withdraw.id == withdrawId
            case .eth(let withdraw):
                return withdraw.id == withdrawId
            }
        })
    }
    
    fileprivate func findSidechainERC20TokenIn(_ array: [ERC20Token], tokenId: String) -> ERC20Token? {
        
        return array.first(where: { $0.id == tokenId })
    }
    
    fileprivate func findSidechainERC20DepositIn(_ array: [ERC20Deposit], depositId: String) -> ERC20Deposit? {
        
        return array.first(where: { $0.id == depositId })
    }
    
    fileprivate func findSidechainERC20WithdrawIn(_ array: [ERC20Withdrawal], withdrawId: String) -> ERC20Withdrawal? {
        
        return array.first(where: { $0.id == withdrawId })
    }
    
    fileprivate func findDataToLoadFromHistoryItems(_ items: [HistoryItem]) -> (blockNums: Set<Int>,
                                                                                accountIds: Set<String>,
                                                                                assetIds: Set<String>,
                                                                                depositsIds: Set<String>,
                                                                                withdrawsIds: Set<String>,
                                                                                erc20TokensIds: Set<String>,
                                                                                erc20DepositsIds: Set<String>,
                                                                                erc20WithdrawsIds: Set<String>) {
        
        let blockNums = fingBlockNumsFromHistoryItems(items)
        let accountIds = findAccountsIds(items)
        let assetIds = findAssetsIds(items)
        let depositsIds = findSidechainDeposits(items)
        let withdrawsIds = findSidechainWithdrawals(items)
        let erc20TokensIds = findSidechainERC20Tokens(items)
        let erc20WithdrawsIds = findSidechainERC20Withdrawals(items)
        let erc20DepositsIds = findSidechainERC20Deposits(items)
        return (blockNums, accountIds, assetIds,
                depositsIds, withdrawsIds,
                erc20TokensIds, erc20DepositsIds, erc20WithdrawsIds)
    }
    
    fileprivate func fingBlockNumsFromHistoryItems(_ items: [HistoryItem]) -> Set<Int> {
        
        var blocksNums = Set<Int>()
        items.forEach {
            blocksNums.insert($0.blockNum)
        }
    
        return blocksNums
    }
    
    // swiftlint:disable function_body_length
    fileprivate func findAccountsIds(_ items: [HistoryItem]) -> Set<String> {
        
        var accountsIds = Set<String>()
        
        items.forEach {
            
            guard let operation = $0.operation else {
                return
            }
            
            if let operation = operation as? TransferOperation {
                accountsIds.insert(operation.fromAccount.id)
                accountsIds.insert(operation.toAccount.id)
                return
            }
            
            if let operation = operation as? AccountUpdateOperation {
                accountsIds.insert(operation.account.id)
                return
            }
            
            if let operation = operation as? CreateAssetOperation {
                if let id = operation.asset.issuer?.id {
                    accountsIds.insert(id)
                    return
                }
            }
            
            if let operation = operation as? IssueAssetOperation {
                accountsIds.insert(operation.issuer.id)
                accountsIds.insert(operation.issueToAccount.id)
                return
            }
            
            if let operation = operation as? AccountCreateOperation {
                accountsIds.insert(operation.registrar.id)
                return
            }
            
            if let operation = operation as? CallContractOperation {
                accountsIds.insert(operation.registrar.id)
                return
            }
            
            if let operation = operation as? CreateContractOperation {
                accountsIds.insert(operation.registrar.id)
                return
            }
            
            if let operation = operation as? BlockRewardOperation {
                accountsIds.insert(operation.receiver.id)
                return
            }
            
            if let operation = operation as? ContractFundPoolOperation {
                accountsIds.insert(operation.sender.id)
                return
            }
            
            if let operation = operation as? SidechainETHCreateAddressOperation {
                accountsIds.insert(operation.account.id)
                return
            }
            
            if let operation = operation as? SidechainETHDepositOperation {
                accountsIds.insert(operation.account.id)
                accountsIds.insert(operation.committeeMember.id)
                return
            }
            
            if let operation = operation as? SidechainETHWithdrawOperation {
                accountsIds.insert(operation.account.id)
                return
            }
            
            if let operation = operation as? SidechainETHApproveAddressOperation {
                accountsIds.insert(operation.account.id)
                accountsIds.insert(operation.committeeMember.id)
                return
            }
            
            if let operation = operation as? SidechainIssueOperation {
                accountsIds.insert(operation.account.id)
                return
            }
            
            if let operation = operation as? SidechainBurnOperation {
                accountsIds.insert(operation.account.id)
                return
            }
            
            if let operation = operation as? SidechainBTCCreateAddressOperation {
                accountsIds.insert(operation.account.id)
                return
            }
            
            if let operation = operation as? SidechainBTCCreateIntermediateDepositOperation {
                accountsIds.insert(operation.account.id)
                accountsIds.insert(operation.committeeMember.id)
                return
            }
            
            if let operation = operation as? SidechainBTCWithdrawOperation {
                accountsIds.insert(operation.account.id)
                return
            }

            if let operation = operation as? SidechainERC20RegisterTokenOperation {
                accountsIds.insert(operation.account.id)
                return
            }

            if let operation = operation as? SidechainERC20DepositTokenOperation {
                accountsIds.insert(operation.account.id)
                accountsIds.insert(operation.committeeMember.id)
                return
            }
            
            if let operation = operation as? SidechainERC20WithdrawTokenOperation {
                accountsIds.insert(operation.account.id)
                return
            }
            
            if let operation = operation as? SidechainERC20IssueOperation {
                accountsIds.insert(operation.account.id)
                return
            }
            
            if let operation = operation as? SidechainERC20BurnOperation {
                accountsIds.insert(operation.account.id)
                return
            }
        }
        
        return accountsIds
    }
    // swiftlint:enable function_body_length
    
    fileprivate func findAssetsIds(_ items: [HistoryItem]) -> Set<String> {
        
        var assetsIds = Set<String>()
        
        items.forEach {
            
            guard let operation = $0.operation else {
                return
            }
            
            assetsIds.insert(operation.fee.asset.id)
            
            if let operation = operation as? TransferOperation {
                assetsIds.insert(operation.transferAmount.asset.id)
                return
            }
            
            if let operation = operation as? CallContractOperation {
                assetsIds.insert(operation.value.asset.id)
                return
            }
            
            if let operation = operation as? CreateContractOperation {
                assetsIds.insert(operation.value.asset.id)
                if let supportedAssetId = operation.supportedAsset.object?.id {
                    assetsIds.insert(supportedAssetId)
                }
                return
            }
            
            if operation is CreateAssetOperation {
                if let assetId = $0.result[safe: 1] as? String {
                    assetsIds.insert(assetId)
                }
                return
            }
            
            if let operation = operation as? IssueAssetOperation {
                assetsIds.insert(operation.assetToIssue.asset.id)
                return
            }
            
            if let operation = operation as? ContractFundPoolOperation {
                assetsIds.insert(operation.value.asset.id)
                return
            }
            
            if let operation = operation as? ContractInternalCallOperation {
                assetsIds.insert(operation.value.asset.id)
                return
            }
            
            if let operation = operation as? SidechainIssueOperation {
                assetsIds.insert(operation.value.asset.id)
                return
            }
            
            if let operation = operation as? SidechainBurnOperation {
                assetsIds.insert(operation.value.asset.id)
                return
            }
        }
        
        return assetsIds
    }
    
    fileprivate func findSidechainDeposits(_ items: [HistoryItem]) -> Set<String> {
        
        var depositsId = Set<String>()
        
        items.forEach {
            
            guard let operation = $0.operation else {
                return
            }
            
            if let operation = operation as? SidechainIssueOperation {
                depositsId.insert(operation.depositId)
                return
            }
        }
        
        return depositsId
    }
    
    fileprivate func findSidechainWithdrawals(_ items: [HistoryItem]) -> Set<String> {
        
        var withdrawalsId = Set<String>()
        
        items.forEach {
            
            guard let operation = $0.operation else {
                return
            }
            
            if let operation = operation as? SidechainBurnOperation {
                withdrawalsId.insert(operation.withdrawId)
                return
            }
        }
        
        return withdrawalsId
    }
    
    fileprivate func findSidechainERC20Tokens(_ items: [HistoryItem]) -> Set<String> {
        
        var erc20TokensId = Set<String>()
        
        items.forEach {
            
            guard let operation = $0.operation else {
                return
            }
            
            if let operation = operation as? SidechainERC20IssueOperation {
                erc20TokensId.insert(operation.token.id)
                return
            }
            
            if let operation = operation as? SidechainERC20BurnOperation {
                erc20TokensId.insert(operation.token.id)
                return
            }
            
            if let operation = operation as? SidechainERC20WithdrawTokenOperation {
                erc20TokensId.insert(operation.token.id)
                return
            }
        }
        
        return erc20TokensId
    }
    
    fileprivate func findSidechainERC20Deposits(_ items: [HistoryItem]) -> Set<String> {
        
        var erc20DepositsId = Set<String>()
        
        items.forEach {
            
            guard let operation = $0.operation else {
                return
            }
            
            if let operation = operation as? SidechainERC20IssueOperation {
                erc20DepositsId.insert(operation.depositId)
                return
            }
        }
        
        return erc20DepositsId
    }
    
    fileprivate func findSidechainERC20Withdrawals(_ items: [HistoryItem]) -> Set<String> {
        
        var erc20WithdrawalsId = Set<String>()
        
        items.forEach {
            
            guard let operation = $0.operation else {
                return
            }
            
            if let operation = operation as? SidechainERC20BurnOperation {
                erc20WithdrawalsId.insert(operation.withdrawId)
                return
            }
        }
        
        return erc20WithdrawalsId
    }
}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
