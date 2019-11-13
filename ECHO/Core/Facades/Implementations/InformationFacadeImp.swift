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
final public class InformationFacadeImp: InformationFacade, ECHOQueueble {
    
    var queues: [ECHOQueue]
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
        self.queues = [ECHOQueue]()
        
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
        case operationID
        case notice
        case noticeHandler
        case task
        case nonce
    }
    
    public func registerAccount(name: String, wif: String, completion: @escaping Completion<Bool>, noticeHandler: NoticeHandler?) {
        
        let createAccountQueue = ECHOQueue()
        queues.append(createAccountQueue)
        
        // Get Account
        let getAccountsOperationInitParams = (createAccountQueue,
                                              services.databaseService,
                                              name)
        let getAccountsOperation = GetIsReservedAccountQueueOperation<Bool>(initParams: getAccountsOperationInitParams,
                                                                          completion: completion)
        getAccountsOperation.defaultError = ECHOError.invalidCredentials
        
        // Create Account
        let requestTaskOperation = createRequestRegistrationTask(createAccountQueue,
                                                                       completion: completion)
        let powTaskOperation = createPoWTaskCalculatingOperation(createAccountQueue, completion: completion)
        let submitOperation = createSubmitRegistrationSolutionOperation(createAccountQueue,
                                                                        name: name,
                                                                        wif: wif,
                                                                        completion: completion)
        
        // Completion
        let completionOperation = createCompletionOperation(queue: createAccountQueue)
        
        createAccountQueue.addOperation(getAccountsOperation)
        createAccountQueue.addOperation(requestTaskOperation)
        createAccountQueue.addOperation(powTaskOperation)
        createAccountQueue.addOperation(submitOperation)

        //Notice handler
        if let noticeHandler = noticeHandler {
            createAccountQueue.saveValue(noticeHandler, forKey: CreationAccountResultsKeys.noticeHandler.rawValue)
            let noticeHandleOperation = createNoticeHandleOperation(createAccountQueue)
            createAccountQueue.addOperation(noticeHandleOperation)
        }
        
        createAccountQueue.setCompletionOperation(completionOperation)
    }
    
    fileprivate func createRequestRegistrationTask(_ queue: ECHOQueue,
                                                   completion: @escaping Completion<Bool>) -> Operation {
        
        let operation = BlockOperation()

        operation.addExecutionBlock { [weak operation, weak queue, weak self] in
            
            guard operation?.isCancelled == false else { return }
            guard let strongSelf = self else { return }
            
            if let _: Account = queue?.getValue(CreationAccountResultsKeys.account.rawValue) {
                queue?.cancelAllOperations()
                let result = Result<Bool, ECHOError>(error: ECHOError.invalidCredentials)
                completion(result)
                return
            }
            
            strongSelf.services.registrationService.requestRegistrationTask { (result) in
                switch result {
                case .success(let task):
                    queue?.saveValue(task, forKey: CreationAccountResultsKeys.task.rawValue)
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<Bool, ECHOError>(error: error)
                    completion(result)
                }

                queue?.startNextOperation()
            }
            
            queue?.waitStartNextOperation()
        }
        
        return operation
    }
    
    fileprivate func createPoWTaskCalculatingOperation(_ queue: ECHOQueue,
                                                       completion: @escaping Completion<Bool>) -> Operation {
        
        let operation = BlockOperation()

        operation.addExecutionBlock { [weak operation, weak queue, weak self] in
            
            guard operation?.isCancelled == false else { return }
            guard let strongSelf = self else { return }
            guard let task: RegistrationTask = queue?.getValue(CreationAccountResultsKeys.task.rawValue) else { return }
            
            guard let blockIdData = Data(hex: task.blockId) else {
                queue?.cancelAllOperations()
                let result = Result<Bool, ECHOError>(error: ECHOError.encodableMapping)
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
                let nonceData = Data.fromUint64(nonce)
                let sha256Data = constantData + nonceData
                let result = strongSelf.cryptoCore.sha256(sha256Data)
                
                var isValid = true
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
                                                               completion: @escaping Completion<Bool>) -> Operation {
        
        let operation = BlockOperation()

        operation.addExecutionBlock { [weak operation, weak queue, weak self] in
            
            guard operation?.isCancelled == false else { return }
            guard let strongSelf = self else { return }
            guard let task: RegistrationTask = queue?.getValue(CreationAccountResultsKeys.task.rawValue) else { return }
            guard let nonce: UInt = queue?.getValue(CreationAccountResultsKeys.nonce.rawValue) else { return }
            
            guard let keychain = ECHOKeychainEd25519(wif: wif, core: strongSelf.cryptoCore) else {
                queue?.cancelAllOperations()
                let result = Result<Bool, ECHOError>(error: ECHOError.invalidWIF)
                completion(result)
                return
            }
            
            let key = strongSelf.network.echorandPrefix.rawValue + keychain.publicAddress()
            
            let regService = strongSelf.services.registrationService
            let operationID = regService.submitRegistrationSolution(name: name,
                                                                    activeKey: key,
                                                                    echorandKey: key,
                                                                    nonce: nonce,
                                                                    randNum: task.randNum.uintValue) { (result) in
                switch result {
                case .success(let value):
                    if value == false {
                        queue?.cancelAllOperations()
                        let result = Result<Bool, ECHOError>(error: ECHOError.invalidCredentials)
                        completion(result)
                    } else {
                        let result = Result<Bool, ECHOError>(value: true)
                        completion(result)
                    }
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<Bool, ECHOError>(error: error)
                    completion(result)
                }
            }
            
            queue?.saveValue(operationID, forKey: CreationAccountResultsKeys.operationID.rawValue)
            queue?.waitStartNextOperation()
        }
        
        return operation
    }
    
    fileprivate func createNoticeHandleOperation(_ queue: ECHOQueue) -> Operation {
        
        let noticeOperation = BlockOperation()
        
        noticeOperation.addExecutionBlock { [weak noticeOperation, weak queue, weak self] in
            
            guard noticeOperation?.isCancelled == false else { return }
            guard self != nil else { return }
            guard let noticeHandler: NoticeHandler = queue?.getValue(CreationAccountResultsKeys.noticeHandler.rawValue) else { return }
            guard let notice: ECHONotification = queue?.getValue(CreationAccountResultsKeys.notice.rawValue) else { return }
            
            noticeHandler(notice)
        }
        
        return noticeOperation
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
        case loadedAccounts
        case loadedDepositsIds
        case loadedWithdrawalsIds
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
        let getDepositsEthOperation = createGetDepositsEthOperation(accountHistoryQueue, completion)
        let getWithdrawsEthOperation = createGetWithdrawsEthOperation(accountHistoryQueue, completion)
        let mergeBlocksToHistoryOperation = createMergeBlocksInHistoryOperation(accountHistoryQueue, completion)
        let mergeAccountsToHistoryOperation = createMergeAccountsInHistoryOperation(accountHistoryQueue, completion)
        let mergeAssetsToHistoryOperation = createMergeAssetsInHistoryOperation(accountHistoryQueue, completion)
        let mergeDepositsEthToHistoryOperation = createMergeDepositsEthInHistoryOperation(accountHistoryQueue, completion)
        let mergeWithdrawEthInHistoryOperation = createMergeWithdrawEthInHistoryOperation(accountHistoryQueue, completion)
        
        // Completion
        let historyCompletionOperation = createHistoryComletionOperation(accountHistoryQueue, completion)
        let completionOperation = createCompletionOperation(queue: accountHistoryQueue)
        
        accountHistoryQueue.addOperation(getAccountOperation)
        accountHistoryQueue.addOperation(getHistoryOperation)
        accountHistoryQueue.addOperation(getBlocksOperation)
        accountHistoryQueue.addOperation(getAccountsOperation)
        accountHistoryQueue.addOperation(getAssetsOperation)
        accountHistoryQueue.addOperation(getDepositsEthOperation)
        accountHistoryQueue.addOperation(getWithdrawsEthOperation)
        accountHistoryQueue.addOperation(mergeBlocksToHistoryOperation)
        accountHistoryQueue.addOperation(mergeAccountsToHistoryOperation)
        accountHistoryQueue.addOperation(mergeAssetsToHistoryOperation)
        accountHistoryQueue.addOperation(mergeDepositsEthToHistoryOperation)
        accountHistoryQueue.addOperation(mergeWithdrawEthInHistoryOperation)
        accountHistoryQueue.addOperation(historyCompletionOperation)
    
        accountHistoryQueue.setCompletionOperation(completionOperation)
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
    
    fileprivate func createGetAccountsOperation(_ queue: ECHOQueue, _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
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
    
    fileprivate func createGetDepositsEthOperation(_ queue: ECHOQueue, _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let getDepositsEthOperation = BlockOperation()
        
        getDepositsEthOperation.addExecutionBlock { [weak getDepositsEthOperation, weak queue, weak self] in
            
            guard getDepositsEthOperation?.isCancelled == false else { return }
            guard let depositsIds: Set<String> = queue?.getValue(AccountHistoryResultsKeys.findedDepositsIds.rawValue) else { return }
            
            let depositsIdsArray = depositsIds.map { $0 }
            
            self?.services.databaseService.getObjects(type: EthDeposit.self,
                                                      objectsIds: depositsIdsArray,
                                                      completion: { (result) in
                
                switch result {
                case .success(let deposits):
                    queue?.saveValue(deposits, forKey: AccountHistoryResultsKeys.loadedDepositsIds.rawValue)
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<[HistoryItem], ECHOError>(error: error)
                    completion(result)
                }
                
                queue?.startNextOperation()
            })
            
            queue?.waitStartNextOperation()
        }
        
        return getDepositsEthOperation
    }
    
    fileprivate func createGetWithdrawsEthOperation(_ queue: ECHOQueue, _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let getWithdrawsEthOperation = BlockOperation()
        
        getWithdrawsEthOperation.addExecutionBlock { [weak getWithdrawsEthOperation, weak queue, weak self] in
            
            guard getWithdrawsEthOperation?.isCancelled == false else { return }
            guard let withdrawsIds: Set<String> = queue?.getValue(AccountHistoryResultsKeys.findedWithdrawalsIds.rawValue) else { return }
            
            let withdrawsIdsArray = withdrawsIds.map { $0 }
            
            self?.services.databaseService.getObjects(type: EthWithdrawal.self,
                                                      objectsIds: withdrawsIdsArray,
                                                      completion: { (result) in
                                                        
                switch result {
                case .success(let deposits):
                    queue?.saveValue(deposits, forKey: AccountHistoryResultsKeys.loadedWithdrawalsIds.rawValue)
                case .failure(let error):
                    queue?.cancelAllOperations()
                    let result = Result<[HistoryItem], ECHOError>(error: error)
                    completion(result)
                }
                
                queue?.startNextOperation()
            })
            
            queue?.waitStartNextOperation()
        }
        
        return getWithdrawsEthOperation
    }
    
    fileprivate func createMergeBlocksInHistoryOperation(_ queue: ECHOQueue, _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let mergeBlocksInHistoryOperation = BlockOperation()
        
        mergeBlocksInHistoryOperation.addExecutionBlock { [weak mergeBlocksInHistoryOperation, weak queue] in
            
            guard mergeBlocksInHistoryOperation?.isCancelled == false else { return }
            guard var history: [HistoryItem] = queue?.getValue(AccountHistoryResultsKeys.historyItems.rawValue) else { return }
            guard let blocks: [Int: Block] = queue?.getValue(AccountHistoryResultsKeys.loadedBlocks.rawValue) else { return }
            
            for index in 0..<history.count {
                
                var historyItem = history[index]
                
                guard let findedBlock = blocks[historyItem.blockNum] else { continue }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = Settings.defaultDateFormat
                dateFormatter.locale = Locale(identifier: Settings.localeIdentifier)

                historyItem.timestamp = dateFormatter.date(from: findedBlock.timestamp)
                
                history[index] = historyItem
            }
            
            queue?.saveValue(history, forKey: AccountHistoryResultsKeys.historyItems.rawValue)
        }
        
        return mergeBlocksInHistoryOperation
    }
    
    fileprivate func createMergeAccountsInHistoryOperation(_ queue: ECHOQueue, _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
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
                
                if var operation = operation as? SidechainETHCreateAddressOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.account.id)
                    operation.changeAccount(account: account)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainETHWithdrawOperation {
                    let account = self?.findAccountIn(accounts, accountId: operation.account.id)
                    operation.changeAccount(account: account)
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
                
                history[index] = historyItem
            }
            
            queue?.saveValue(history, forKey: AccountHistoryResultsKeys.historyItems.rawValue)
        }
        
        return mergeAccountsInHistoryOperation
    }
    
    fileprivate func createMergeDepositsEthInHistoryOperation(_ queue: ECHOQueue, _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let mergeDepositsEthInHistoryOperation = BlockOperation()
        
        mergeDepositsEthInHistoryOperation.addExecutionBlock { [weak mergeDepositsEthInHistoryOperation, weak self, weak queue] in
            
            guard mergeDepositsEthInHistoryOperation?.isCancelled == false else { return }
            guard var history: [HistoryItem] = queue?.getValue(AccountHistoryResultsKeys.historyItems.rawValue) else { return }
            guard let deposits: [EthDeposit] = queue?.getValue(AccountHistoryResultsKeys.loadedDepositsIds.rawValue) else { return }
            
            for index in 0..<history.count {
                
                var historyItem = history[index]
                
                guard let operation = historyItem.operation else { continue }
                
                if var operation = operation as? SidechainIssueOperation {
                    let deposit = self?.findDepositEthIn(deposits, depositId: operation.depositId)
                    operation.deposit = deposit
                    historyItem.operation = operation
                }
                
                history[index] = historyItem
            }
            
            queue?.saveValue(history, forKey: AccountHistoryResultsKeys.historyItems.rawValue)
        }
        
        return mergeDepositsEthInHistoryOperation
    }
    
    fileprivate func createMergeWithdrawEthInHistoryOperation(_ queue: ECHOQueue, _ completion: @escaping Completion<[HistoryItem]>) -> Operation {
        
        let mergeDepositsEthInHistoryOperation = BlockOperation()
        
        mergeDepositsEthInHistoryOperation.addExecutionBlock { [weak mergeDepositsEthInHistoryOperation, weak self, weak queue] in
            
            guard mergeDepositsEthInHistoryOperation?.isCancelled == false else { return }
            guard var history: [HistoryItem] = queue?.getValue(AccountHistoryResultsKeys.historyItems.rawValue) else { return }
            guard let withdraws: [EthWithdrawal] = queue?.getValue(AccountHistoryResultsKeys.loadedWithdrawalsIds.rawValue) else { return }
            
            for index in 0..<history.count {
                
                var historyItem = history[index]
                
                guard let operation = historyItem.operation else { continue }
                
                if var operation = operation as? SidechainBurnOperation {
                    let withdraw = self?.findWithdrawsEthIn(withdraws, withdrawId: operation.withdrawId)
                    operation.withdraw = withdraw
                    historyItem.operation = operation
                }
                
                history[index] = historyItem
            }
            
            queue?.saveValue(history, forKey: AccountHistoryResultsKeys.historyItems.rawValue)
        }
        
        return mergeDepositsEthInHistoryOperation
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
                
                if var operation = operation as? SidechainETHCreateAddressOperation {
                    let feeAsset = self?.findAssetsIn(assets, assetId: operation.fee.asset.id)
                    operation.changeAssets(feeAsset: feeAsset)
                    historyItem.operation = operation
                }
                
                if var operation = operation as? SidechainETHWithdrawOperation {
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
    
    fileprivate func findDepositEthIn(_ array: [EthDeposit], depositId: String) -> EthDeposit? {
        
        return array.first(where: {$0.id == depositId})
    }
    
    fileprivate func findWithdrawsEthIn(_ array: [EthWithdrawal], withdrawId: String) -> EthWithdrawal? {
        
        return array.first(where: {$0.id == withdrawId})
    }
    
    fileprivate func findDataToLoadFromHistoryItems(_ items: [HistoryItem]) -> (blockNums: Set<Int>,
                                                                                accountIds: Set<String>,
                                                                                assetIds: Set<String>,
                                                                                depositsIds: Set<String>,
                                                                                withdrawsIds: Set<String>) {
        
        let blockNums = fingBlockNumsFromHistoryItems(items)
        let accountIds = findAccountsIds(items)
        let assetIds = findAssetsIds(items)
        let depositsIds = findDepositsEth(items)
        let withdrawsIds = findWithdrawalsEth(items)
        return (blockNums, accountIds, assetIds, depositsIds, withdrawsIds)
    }
    
    fileprivate func fingBlockNumsFromHistoryItems(_ items: [HistoryItem]) -> Set<Int> {
        
        var blocksNums = Set<Int>()
        items.forEach {
            blocksNums.insert($0.blockNum)
        }
    
        return blocksNums
    }
    
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
            
            if let operation = operation as? SidechainETHCreateAddressOperation {
                accountsIds.insert(operation.account.id)
                return
            }
            
            if let operation = operation as? SidechainETHWithdrawOperation {
                accountsIds.insert(operation.account.id)
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
        }
        
        return accountsIds
    }
    
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
    
    fileprivate func findDepositsEth(_ items: [HistoryItem]) -> Set<String> {
        
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
    
    fileprivate func findWithdrawalsEth(_ items: [HistoryItem]) -> Set<String> {
        
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
}

extension InformationFacadeImp: NoticeEventDelegate {
    
    public func didReceiveNotification(notification: ECHONotification) {
        
        switch notification.params {
        case .array(let array):
            if let noticeOperationId = array.first as? Int {

                for queue in queues {

                    if let queueTransferOperationId: Int = queue.getValue(CreationAccountResultsKeys.operationID.rawValue),
                        queueTransferOperationId == noticeOperationId {
                        queue.saveValue(notification, forKey: CreationAccountResultsKeys.notice.rawValue)
                        queue.startNextOperation()
                    }
                }
            }
        default:
            break
        }
    }
}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
