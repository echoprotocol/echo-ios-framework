//
//  DatabaseApiServiceImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

private typealias AccountsService = DatabaseApiServiceImp
private typealias GlobalsService = DatabaseApiServiceImp
private typealias AssetsService = DatabaseApiServiceImp
private typealias SubscriptionService = DatabaseApiServiceImp
private typealias AuthorityAndValidationService = DatabaseApiServiceImp
private typealias BlocksAndTransactionsService = DatabaseApiServiceImp
private typealias ContractsService = DatabaseApiServiceImp
private typealias SidechainService = DatabaseApiServiceImp
private typealias EthService = DatabaseApiServiceImp
private typealias BtcService = DatabaseApiServiceImp
private typealias ERC20Service = DatabaseApiServiceImp
private typealias BalanceService = DatabaseApiServiceImp

/**
     Implementation of [DatabaseApiService](DatabaseApiService)

     Encapsulates logic of preparing API calls to [SocketCoreComponent](SocketCoreComponent)
 */
final class DatabaseApiServiceImp: DatabaseApiService {
    
    var apiIdentifire: Int = 0
    let socketCore: SocketCoreComponent
    
    required init(socketCore: SocketCoreComponent) {
        self.socketCore = socketCore
    }
    
    func sendCustomOperation(operation: CustomSocketOperation) {
        
        operation.setApiId(apiIdentifire)
        operation.setOperationId(socketCore.nextOperationId())
        
        socketCore.send(operation: operation)
    }
}

extension AccountsService {
    
    func getFullAccount(nameOrIds: [String], shoudSubscribe: Bool, completion: @escaping Completion<[String: UserAccount]>) {
        
        let operation = FullAccountSocketOperation(method: .call,
                                                   operationId: socketCore.nextOperationId(),
                                                   apiId: apiIdentifire,
                                                   accountsIds: nameOrIds,
                                                   shoudSubscribe: shoudSubscribe,
                                                   completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func getKeyReferences(keys: [String], completion: @escaping Completion<[[String]]>) {
        
        let operation = GetKeyReferencesSocketOperation(method: .call,
                                                        operationId: socketCore.nextOperationId(),
                                                        apiId: apiIdentifire,
                                                        keys: keys,
                                                        completion: completion)
        
        socketCore.send(operation: operation)
    }
}

extension GlobalsService {
    
    func getGlobalProperties(completion: @escaping Completion<GlobalProperties>) {
        
        let operation = GetGlobalPropertiesSocketOperation(method: .call,
                                                           operationId: socketCore.nextOperationId(),
                                                           apiId: apiIdentifire,
                                                           completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func getChainId(completion: @escaping Completion<String>) {
        
        let operation = GetChainIdSocketOperation(method: .call,
                                                  operationId: socketCore.nextOperationId(),
                                                  apiId: apiIdentifire,
                                                  completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func getObjects<T>(type: T.Type, objectsIds: [String], completion: @escaping Completion<[T]>) where T: Decodable {
        
        let operation = GetObjectsSocketOperation<T>(method: .call,
                                                     operationId: socketCore.nextOperationId(),
                                                     apiId: apiIdentifire,
                                                     identifiers: objectsIds,
                                                     completion: completion)
        
        socketCore.send(operation: operation)
    }
}

extension AuthorityAndValidationService {
    
    func getRequiredFees(operations: [BaseOperation], asset: Asset, completion: @escaping Completion<[FeeType]>) {
        
        let operation = RequiredFeeSocketOperation(method: .call,
                                                   operationId: socketCore.nextOperationId(),
                                                   apiId: apiIdentifire,
                                                   operations: operations,
                                                   asset: asset,
                                                   completion: completion)
        
        socketCore.send(operation: operation)
    }
}

extension BlocksAndTransactionsService {
    
    func getBlockData(completion: @escaping Completion<BlockData>) {
        
        let operation = BlockDataSocketOperation(method: .call, operationId: socketCore.nextOperationId(), apiId: apiIdentifire) { (result) in
            switch result {
            case .success(let dynamicProperties):
                
                let headBlockId = dynamicProperties.headBlockId
                let headBlockNumber = dynamicProperties.headBlockNumber
                
                let dateFormatter = DateFormatter()
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                dateFormatter.dateFormat = Settings.defaultDateFormat
                dateFormatter.locale = Locale(identifier: Settings.localeIdentifier)
                
                let date = dateFormatter.date(from: dynamicProperties.time)
                let interval = date?.timeIntervalSince1970 ?? 0
                let expirationTime = Int(interval)
                
                let blockData = BlockData(
                    headBlockNumber: headBlockNumber,
                    headBlockId: headBlockId,
                    relativeExpiration: expirationTime
                )
                let result = Result<BlockData, ECHOError>(value: blockData)
                completion(result)
            case .failure(let error):
                let result = Result<BlockData, ECHOError>(error: error)
                completion(result)
            }
        }
        
        socketCore.send(operation: operation)
    }
    
    func getBlock(blockNumber: Int, completion:@escaping Completion<Block>) {
        
        let operation = GetBlockSocketOperation(method: .call,
                                                operationId: socketCore.nextOperationId(),
                                                apiId: apiIdentifire,
                                                blockNumber: blockNumber,
                                                completion: completion)
        
        socketCore.send(operation: operation)
    }
}

extension SubscriptionService {
    
    func setSubscribeCallback(completion: @escaping Completion<Void>) {
        let operation = SetSubscribeCallbackSocketOperation(method: .call,
                                                            operationId: socketCore.nextOperationId(),
                                                            apiId: apiIdentifire,
                                                            needClearFilter: false,
                                                            completion: completion)
        socketCore.send(operation: operation)
    }
    
    func setBlockAppliedCallback(blockId: String, completion: @escaping Completion<Void>) {
        
        let operation = SetBlockAppliedCollbackSocketOperation(method: .call,
                                                               operationId: socketCore.nextOperationId(),
                                                               apiId: apiIdentifire,
                                                               blockId: blockId,
                                                               completion: completion)
        socketCore.send(operation: operation)
    }
    
    func subscribeContractLogs(contractId: String, completion: @escaping Completion<Void>) {
        
        let operation = SubscribeContractLogsSocketOperation(method: .call,
                                                             operationId: socketCore.nextOperationId(),
                                                             apiId: apiIdentifire,
                                                             contractId: contractId,
                                                             completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func subscribeContracts(contractsIds: [String], completion: @escaping Completion<Void>) {
        
        let operation = SubscribeContractsSocketOperation(method: .call,
                                                          operationId: socketCore.nextOperationId(),
                                                          apiId: apiIdentifire,
                                                          contractIds: contractsIds,
                                                          completion: completion)
        socketCore.send(operation: operation)
    }
}

extension AssetsService {
    
    func getAssets(assetIds: [String], completion: @escaping Completion<[Asset]>) {
        
        let operation = GetAssetsSocketOperation(method: .call,
                                                 operationId: socketCore.nextOperationId(),
                                                 apiId: apiIdentifire,
                                                 assestsIds: assetIds,
                                                 completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func listAssets(lowerBound: String, limit: Int, completion: @escaping Completion<[Asset]>) {
        let operation = ListAssetsSocketOperation(method: .call,
                                                  operationId: socketCore.nextOperationId(),
                                                  apiId: apiIdentifire,
                                                  lowerBound: lowerBound,
                                                  limit: limit,
                                                  completion: completion)
        
        socketCore.send(operation: operation)
    }
}

extension ContractsService {
    
    func getContractResult(contractResultId: String, completion: @escaping Completion<ContractResultEnum>) {
        
        let operation = GetContractResultSocketOperation(method: .call,
                                                         operationId: socketCore.nextOperationId(),
                                                         apiId: apiIdentifire,
                                                         contractResultId: contractResultId,
                                                         completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func getContractLogs(contractId: String, fromBlock: Int, toBlock: Int, completion: @escaping Completion<Void>) -> Int {
        
        let operationId = socketCore.nextOperationId()
        let operation = GetContractLogsSocketOperation(method: .call,
                                                       operationId: operationId,
                                                       apiId: apiIdentifire,
                                                       contractId: contractId,
                                                       fromBlock: fromBlock,
                                                       toBlock: toBlock,
                                                       completion: completion)
        
        socketCore.send(operation: operation)
        return operationId
    }
    
    func getContracts(contractIds: [String], completion: @escaping Completion<[ContractInfo]>) {
        
        let extractedExpr = GetContractsSocketOperation(method: .call,
                                                        operationId: socketCore.nextOperationId(),
                                                        apiId: apiIdentifire,
                                                        contractIds: contractIds,
                                                        completion: completion)
        let operation = extractedExpr
        
        socketCore.send(operation: operation)
    }
    
    func getContract(contractId: String, completion: @escaping Completion<ContractStructEnum>) {
        
        let operation = GetContractSocketOperaton(method: .call,
                                                  operationId: socketCore.nextOperationId(),
                                                  apiId: apiIdentifire,
                                                  contractId: contractId,
                                                  completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func callContractNoChangingState(contract: Contract,
                                     amount: UInt,
                                     asset: Asset,
                                     account: Account,
                                     contractCode: String,
                                     completion: @escaping Completion<String>) {
        
        let operation = QueryContractSocketOperation(method: .call,
                                                    operationId: socketCore.nextOperationId(),
                                                    apiId: apiIdentifire,
                                                    contractId: contract.id,
                                                    registrarId: account.id,
                                                    amount: amount,
                                                    assetId: asset.id,
                                                    code: contractCode,
                                                    completion: completion)
        
        socketCore.send(operation: operation)
    }
}

extension SidechainService {
    func getAccountDeposits(accountId: String, type: SidechainType?, completion: @escaping Completion<[SidechainDepositEnum]>) {
        
        let operation = GetAccountDepositsSocketOperation(method: .call,
                                                          operationId: socketCore.nextOperationId(),
                                                          apiId: apiIdentifire,
                                                          accountId: accountId,
                                                          type: type,
                                                          completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func getAccountWithdrawals(accountId: String, type: SidechainType?, completion: @escaping Completion<[SidechainWithdrawalEnum]>) {
        
        let operation = GetAccountWithdrawalsSocketOperation(method: .call,
                                                             operationId: socketCore.nextOperationId(),
                                                             apiId: apiIdentifire,
                                                             accountId: accountId,
                                                             type: type,
                                                             completion: completion)
        
        socketCore.send(operation: operation)
    }
}

extension EthService {
    func getEthAddress(accountId: String, completion: @escaping Completion<EthAddress?>) {
        
        let operation = GetEthAddressSocketOperation(method: .call,
                                                     operationId: socketCore.nextOperationId(),
                                                     apiId: apiIdentifire,
                                                     accountId: accountId,
                                                     completion: completion)
    
        socketCore.send(operation: operation)
    }
}

extension BtcService {
    func getBtcAddress(accountId: String, completion: @escaping Completion<BtcAddress?>) {
        
        let operation = GetBtcAddressSocketOperation(method: .call,
                                                     operationId: socketCore.nextOperationId(),
                                                     apiId: apiIdentifire,
                                                     accountId: accountId,
                                                     completion: completion)
        
        socketCore.send(operation: operation)
    }
}

extension ERC20Service {
    
    func getERC20Token(by value: String, completion: @escaping Completion<ERC20Token?>) {
        
        let operation = GetERC20TokenSocketOperation(method: .call,
                                                     operationId: socketCore.nextOperationId(),
                                                     apiId: apiIdentifire,
                                                     ethAddressOrId: value,
                                                     completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func checkERC20Token(contractId: String, completion: @escaping Completion<Bool>) {
        
        let operation = CheckERC20TokenSocketOperation(method: .call,
                                                       operationId: socketCore.nextOperationId(),
                                                       apiId: apiIdentifire,
                                                       contractId: contractId,
                                                       completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func getERC20AccountDeposits(accountId: String, completion: @escaping Completion<[ERC20Deposit]>) {
        
        let operation = GetERC20AccountDepositsSocketOperation(method: .call,
                                                               operationId: socketCore.nextOperationId(),
                                                               apiId: apiIdentifire,
                                                               accountId: accountId,
                                                               completion: completion)
        
        socketCore.send(operation: operation)
    }
    
    func getERC20AccountWithdrawals(accountId: String, completion: @escaping Completion<[ERC20Withdrawal]>) {
        
        let operation = GetERC20AccountWithdrawalsSocketOperation(method: .call,
                                                                  operationId: socketCore.nextOperationId(),
                                                                  apiId: apiIdentifire,
                                                                  accountId: accountId,
                                                                  completion: completion)
        
        socketCore.send(operation: operation)
    }
}

extension BalanceService {
    func getBalanceObjects(publicKeys: [String], completion: @escaping Completion<[BalanceObject]>) {
        let operation = GetBalanceObjectsSocketOperation(
            method: .call,
            operationId: socketCore.nextOperationId(),
            apiId: apiIdentifire,
            publicKeys: publicKeys,
            completion: completion
        )
        
        socketCore.send(operation: operation)
    }
    
    func getFrozenBalances(accountID: String, completion: @escaping Completion<[FrozenBalanceObject]>) {
        let operation = GetFrozenBalancesSocketOperation(
            method: .call,
            operationId: socketCore.nextOperationId(),
            apiId: apiIdentifire,
            accountID: accountID,
            completion: completion
        )
        
        socketCore.send(operation: operation)
    }
}
