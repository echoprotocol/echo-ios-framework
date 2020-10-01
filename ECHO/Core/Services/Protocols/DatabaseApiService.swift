//
//  DatabaseApiService.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 18.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
 Encapsulates logic, associated with blockchain database API
 
 [Graphene blockchain database API](https://dev-doc.myecho.app/classgraphene_1_1app_1_1database__api.html)
 */
protocol DatabaseApiService: BaseApiService {
    
    /**
     Get the objects corresponding to the provided IDs.
     
     - Parameter objectsIds: IDs of the objects to retrieve
     - Parameter completion: Callback which returns current block data or error
     */
    func getObjects<T>(type: T.Type, objectsIds: [String], completion: @escaping Completion<[T]>) where T: Decodable
    
    /**
     Retrieve the current global property object.
     
     - Parameter completion: Callback which returns [GlobalProperties](GlobalProperties) or error
     */
    func getGlobalProperties(completion: @escaping Completion<GlobalProperties>)
    
    /**
     Retrieves base block information
     
     - Parameter completion: Callback which returns current block data or error
     */
    func getBlockData(completion: @escaping Completion<BlockData>)
    
    /**
     Retrieves full signed block
     
     - Parameter blockNumber: Height of the block to be returned
     - Parameter completion: Callback which returns Block or error
     */
    func getBlock(blockNumber: Int, completion: @escaping Completion<Block>)
    
    /**
     Retrieves blockchain chain id
     
     - Parameter completion: Callback which returns chain id string or error
     */
    func getChainId(completion: @escaping Completion<String>)
    
    /**
     Fetch all objects relevant to the specified accounts and subscribe to updates.
     
     - Parameter nameOrIds: Each item must be the name or ID of an account to retrieve
     - Parameter shoudSubscribe: Flag for subscribe options, true if need to subscribe on changes
     - Parameter completion: Callback which returns accounts or error
     */
    func getFullAccount(nameOrIds: [String], shoudSubscribe: Bool, completion: @escaping Completion<[String: UserAccount]>)
    
    /**
     Fetch all account id relevant to the specified keys.
     
     - Parameter keys: Public keys of account for search
     - Parameter completion: Callback which returns array of arrays of id for each key or error
     */
    func getKeyReferences(keys: [String], completion: @escaping Completion<[[String]]>)
    /**
     Retrieves required fee by asset for ech operation
     
     - Parameter operations: Operations for getting fee
     - Parameter asset: Asset type for fee paying
     - Parameter completion: Callback which returns amounts or error
     */
    func getRequiredFees(operations: [BaseOperation], asset: Asset, completion: @escaping Completion<[FeeType]>)
    
    /**
     Subscribes to listening chain objects
     
     - Parameter completion: Callback which returns status of subscription
     */
    func setSubscribeCallback(completion: @escaping Completion<Void>)
    
    /**
     Subscribes to listening chain objects
     
     - Parameter completion: Callback which returns status of subscription
     */
    func setBlockAppliedCallback(blockId: String, completion: @escaping Completion<Void>)
    
    /**
     Query list of assets by it's ids [assetIds]
     
     - Parameter assetIds: Assets Ids for getting information
     - Parameter completion: Callback which returns [[Asset](Asset)] or error
     */
    func getAssets(assetIds: [String], completion: @escaping Completion<[Asset]>)
    
    /**
     Query list of assets by required asset symbol [lowerBound] with limit [limit]
     
     - Parameter lowerBound: Id of aseet used as lower bound
     - Parameter limit: Count of getting assets
     - Parameter completion: Callback which returns [[Asset](Asset)] or error
     */
    func listAssets(lowerBound: String, limit: Int, completion: @escaping Completion<[Asset]>)
    
    /**
     Return result of contract operation call
     
     - Parameter contractResultId: Contract result id
     - Parameter completion: Callback which returns [ContractResultEnum](ContractResultEnum) or error
     */
    func getContractResult(contractResultId: String, completion: @escaping Completion<ContractResultEnum>)
    
    /**
     Async get contract logs
     
     - Parameter contractId: Contract id for fetching logs
     - Parameter fromBlockId: Number of the earliest block to retrieve
     - Parameter toBlock: Number of the latest block to retrieve
     - Parameter completion: Callback which returns [Bool](Bool) result of call or error. The logs will receive by notice
     - Returns: ID of operation. For notice handle
     */
    func getContractLogs(contractId: String, fromBlock: Int, toBlock: Int, completion: @escaping Completion<Void>) -> Int
    
    /**
     Subscribes to listening contract logs
     
     - Parameter contractId: Contract id for fetching logs
     - Parameter completion: Callback which returns result of call or error
     */
    func subscribeContractLogs(contractId: String, completion: @escaping Completion<Void>)
    
    /**
     Returns contracts called by ids
     
     - Parameter contractIds: Contracts ids for call
     - Parameter completion: Callback which returns an [[ContractInfo](ContractInfo)] or error
     */
    func getContracts(contractIds: [String], completion: @escaping Completion<[ContractInfo]>)
    
    /**
     Return full information about contract
     
     - Parameter contractId: Identifier for contract
     - Parameter completion: Callback which returns an [ContractStructEnum](ContractStructEnum) or error
     */
    func getContract(contractId: String, completion: @escaping Completion<ContractStructEnum>)
    
    /**
     Calls contract method without changing state of blockchain
     
     - Parameter contract: Called contract
     - Parameter amount: Amount for call contract
     - Parameter asset: Asset for call contract
     - Parameter account: Account that call the contract
     - Parameter contractCode: Contract code for execute
     - Parameter completion: Callback which returns an [Bool](Bool) result of call or error
     */
    func callContractNoChangingState(contract: Contract,
                                     amount: UInt,
                                     asset: Asset,
                                     account: Account,
                                     contractCode: String,
                                     completion: @escaping Completion<String>)
    
    /**
     Subscribes to listening contracts changes
     
     - Parameter contractsIds: Contracts ids for subscribe
     - Parameter completion: Callback which [Bool](Bool) as result of call or error
     */
    func subscribeContracts(contractsIds: [String], completion: @escaping Completion<Void>)
    
    /**
     Get created Ethereum addresses
     
     - Parameter accountId: Accoint id
     - Parameter completion: Callback in which the information will return [EthAddress](EthAddress) object if it created or error
     */
    func getEthAddress(accountId: String,
                       completion: @escaping Completion<EthAddress?>)
    
    /**
     Get created Bitcoin addresses
     
     - Parameter accountId: Accoint id
     - Parameter completion: Callback in which the information will return [BtcAddress](BtcAddress) object if it created or error
     */
    func getBtcAddress(accountId: String,
                       completion: @escaping Completion<BtcAddress?>)
    
    /**
     Returns all approved deposits, for the given account id.
     
     - Parameter accountId: Accoint id
     - Parameter completion: Callback in which return Deposits objects or error.
     */
    func getAccountDeposits(accountId: String,
                            type: SidechainType?,
                            completion: @escaping Completion<[SidechainDepositEnum]>)
    
    /**
     Returns all approved withdrawals, for the given account id.
     
     - Parameter accountId: Accoint id
     - Parameter completion: Callback in which return Withdrawals objects or error.
     */
    func getAccountWithdrawals(accountId: String,
                               type: SidechainType?,
                               completion: @escaping Completion<[SidechainWithdrawalEnum]>)
    
    /**
     Returns information about erc20 token, if exist.
     
     - Parameter by: Token address in Ethereum network or token id in Echo network or contract id in Echo network
     - Parameter completion: Callback in which return ERC20Token if exist object or error.
     */
    func getERC20Token(by value: String,
                       completion: @escaping Completion<ERC20Token?>)
    
    /**
     Return true if the contract exists and is ERC20 token contract registered.
     
     - Parameter tokenAddress: Contract identifier in Ethereum network
     - Parameter completion: Callback in which return true if the contract exists and is ERC20 token contract registered.
     */
    func checkERC20Token(contractId: String,
                         completion: @escaping Completion<Bool>)
    
    /**
     Returns all ERC20 deposits, for the given account id.
     
     - Parameter accountId: Accoint id
     - Parameter completion: Callback in which return ERC20Deposit objects or error.
     */
    func getERC20AccountDeposits(accountId: String,
                                 completion: @escaping Completion<[ERC20Deposit]>)
    
    /**
     Returns all ERC20 withdrawals, for the given account id.
     
     - Parameter accountId: Accoint id
     - Parameter completion: Callback in which return ERC20Withdrawal objects or error.
     */
    func getERC20AccountWithdrawals(accountId: String,
                                    completion: @escaping Completion<[ERC20Withdrawal]>)
    
    /**
    Return all unclaimed balance objects for a set of public keys.
    
    - Parameter publicKeys: An array of ed25519 public keys
    - Returns: An array of balances objects.
    */
    func getBalanceObjects(publicKeys: [String], completion: @escaping Completion<[BalanceObject]>)
    
    /**
    Return an array of frozen balances for a set of addresses ID.
    
    - Parameter accountID: The id of account to use
    - Returns: An array of frozen balances.
    */
    func getFrozenBalances(accountID: String, completion: @escaping Completion<[FrozenBalanceObject]>)
}
