# CHANGELOG

## Changelog 5.1.0 - 2020-09-04
Support 0.22 Echo version.

### Added
* LastBlockOfPreviousInterval field in DynamicGlobalProperties object
* BalanceUnfreezingTime field in GlobalProperties object
* EconomyConfig object. And economyConfig field in GlobalProperties object
* RequestBalanceUnfreezeOperation type in OperationType enum
* Getting erc20 token by echo contract id

### Changed
* Fields in BtcDepositAddress and BtcCommitteeMemberIdInScript objects in public now

## Changelog 5.0.0 - 2020-08-25
Support 0.21 Echo version.

### Added
* Notice handler param in createAsset method
* Notice handler param in issueAsset method
* Notice handler param in changeKeys method
* Notice handler param in registerAccount method

### Changed
* All completion blocks with simple result now returns Void instead Bool
* ECHOError.internalError contains ECHOResponseError with code and message instead String message
* Completion and noticeHandler renamed to sendCompletion and confirmNoticeHandler.
* Error handling mechanism. SendCompletion now reports that all preparation is complete and the transaction has been sent successfully. СonfirmNoticeHandler informs about transaction confirmation or confirmation error processing

## Changelog 4.2.2 - 2020-06-05
### Added
* Disconnect socket connection method
* Debug flag in settings for showing logs in console
* Support Swift 5

## Changelog 4.2.1 - 2020-05-29
Integration with chain version 0.19

### Added
* TransactionHash field to BtcWithdrawal, ERC20Withdrawal, ErhAddress, EthDeposit, ETHWithdrawal, SidechainETHApproveAddressOperation, SidechainETHDepositOperation objects

### Removed
* EdSignature field from Block object

### Changed
* ObjectType enum

## Changelog 4.2.0 - 2020-04-23
### Added
* Getting erc20 token by id
* Field evmAddress in SubmitRegistrationSolutionSocketOperation and AccountCreateOperation
* BTCAssetId in GlobalProperties
* Added evmAddress object type
* Field parentOpId in ContractHistory object
* Field ethAccuracy in Contract object

### Changed
* Transaction expiration time calculation
* All BTC classes name

## Changelog 4.1.0 - 2020-01-28
### Changed
* Operations order list
* Get contract logs operation logic
* Internal property names and types

## Changelog 4.0.1 - 2019-12-16
### Added 
* getFeeForWithdrawEthOperation method
* getFeeForWithdrawBtcOperation method
* getFeeForWithdrawERC20Operation method

### Removed
* WIF field from getFeeForCreateContract methods

### Tests
* Added tests to new methods

## Changelog 4.0.0 - 2019-12-03

### Added

#### ERC20 Sidechain
Socket operations:
* GetERC20TokenSocketOperation
* CheckERC20TokenSocketOperation
* GetERC20AccountDepositsSocketOperation
* GetERC20AccountWithdrawalsSocketOperation

Chain operations:
* SidechainERC20RegisterTokenOperation
* SidechainERC20DepositTokenOperation
* SidechainERC20WithdrawTokenOperation
* SidechainERC20IssueOperation
* SidechainERC20BurnOperation

#### BTC Sidechain
Socket operations:
* GetBtcAddressSocketOperation

Chain operations:
* SidechainBTCCreateAddressOperation
* SidechainBTCWithdrawOperation
* SidechainBTCCreateIntermediateDepositOperation

#### Chain operations:
* ContractFundPoolOperation
* BlockRewardOperation

## Changelog 3.7.2 - 2019-11-19

### Fixed
* Fixed ECHOQueue completion operation

## Changelog 3.7.1 - 2019-11-18

### Fixed
* Fixed memory leaks in register account method

## Changelog 3.7.0 - 2019-11-13

### Removed
* networkFeePercentage from Account object
* accountsRegisteredThisInterval from DynamicGlobalProperties object
* nextAvailableVoteId from GlobalProperties object
* maximumCommitteeCount, reservePercentOfFee, networkPercentOfFee, maxPredicateOpcode, accountsPerFeeScale, accountFeeScaleBitshifts from GlobalPropertiesParameters
* blockResult from ObjectTypes

### Changed
* renamed WithdrawalEth to EthWithdrawal
* renamed DepositEth to EthDeposit
* GetContractLogsSocketOperation limit changed to toBlock. Fixed operation JSON
* Added type(SidechainType) field to GetAccountDepositsSocketOperation. Operation returns array of SidechainDepositEnum
* Added type(SidechainType) field to GetAccountWithdrawalsSocketOperation. Operation returns array of SidechainWithdrawalEnum

### Added
* QueryContractSocketOperation added amount field. Fixed operation JSON
* SidechainType enum. It contains .eth and .btc value
* BtcDeposit object
* BtcWithdrawal object
* SidechainDepositEnum. It contains EthDeposit or BtcDeposit
* SidechainWithdrawalEnum. It contains EthWithdrawal or BtcWithdrawal
* Added estimate fee methods for create contract operation(getFeeForCreateContract) 

## Changelog 3.6.0 - 2019-10-18

### Removed

#### DynamicGlobalProperties
* lastRandQuantity

#### OperationType
* contractTransferOperation

#### AccountOptions, Options
* votingAccount
* numCommittee
* votes

#### GlobalProperties
* activeCommitteeMembers

#### SidechainConfig
* waitingBlocks
* waitingETHBlocks

#### Vote

### Added

#### SubmitRegistrationSolutionSocketOperation

#### OperationType
* committeeMemberActivateOperation
* committeeMemberDeactivateOperation
* committeeFrozenBalanceDepositOperation
* committeeFrozenBalanceWithdrawOperation
* contractInternalCreateOperation
* contractInternalCallOperation
* contractSelfdestructOperation
* sidechainBTCCreateIntermediateDepositOperation

#### ContractLogEVM
* blockNum
* trxNum
* opNum

#### Account
* accumulatedReward

#### ObjectType
* committeeFrozenBalance

### Updated

#### SubscribeContractLogsSocketOperation
* Updated input parameters

#### GetContractLogsSocketOperation
* Updated input parameters

#### Registration
* Now registration goes through PoW task solving

## 3.5.1 - 2019-11-12

### Fixed
* EchoQueue memory leaks

### Added
* Added timeount error to all socket operations. Timeount can be changed when setup the framework

### Changed
* Chenged notice callback. Now it returns notice or connectionLost error

### Tests
* Added timeount and connection lost tests

## 3.5.0 - 2019-10-15

### Removed

#### DynamicGlobalProperties
* currentAslot
* recentlyMissedCount

#### GlobalProperties
* blockInterval

#### ObjectType
* budgetRecord

#### Statistics
* pendingFees

#### ContractResultEVM
* gasRefunded

#### OperationType
* accountTransferOperation
* sidechainChangeConfigOperation

### Added

#### AccountOptions
* delegateShare

#### DynamicGlobalProperties
* lastRandQuantity

#### ObjectType
* frozenBalance
* btcAddress
* btcIntermediateDeposit
* btcDeposit
* btcWithdraw
* btcAggregating

#### SidechainConfig
* waitingETHBlocks

### ContractLogEnum
* Added enum which represent evm or x86 contract log
* ContractLogx86

#### OperationType
* balanceFreezeOperation
* balanceUnfreezeOperation
* sidechainERC20IssueOperation
* sidechainERC20BurnOperation
* sidechainBTCCreateAddressOperatio
* sidechainBTCIntermediateDepositOperatio
* sidechainBTCDepositOperatio
* sidechainBTCWithdrawOperatio
* sidechainBTCApproveWithdrawOperatio
* sidechainBTCAggregateOperatio
* blockRewardOperation

#### Tests
* Added tests to subscribeToAccount, subscribeToBlock, subscribeToDynamicGlobalProperties

### Updated

#### Signatures
* signer changed to producer

#### ContractLogsSocketOperation
* Fixed returns parameter to ContractLogEnum

#### SubscribeContractLogsSocketOperation
* Fixed returns parameter to Bool
* Removed fromBlock and toBlock fields

#### AssetAmount
* Fixed AssetAmount mapping for big values

#### Tests
* Updated all tests and constants

## 3.4.0 - 2019-08-16

### Removed

#### AssetOptions:

* marketFeePercent
* maxMarketFee
* whitelistMarkets
* blacklistMarkets

#### BitassetOptions

* forceSettlementDelaySec
* forceSettlementOffsetPercent
* maximumForceSettlementVolume

#### CreateAssetOperation

* isPredictionMarket

#### Account

* membershipExpirationDate
* referrer
* lifetimeReferrer
* lifetimeReferrerFeePercentage

#### FullAccount

* referrerName

#### AccountCreateOperation

* referrer
* referrerPercent

#### GlobalProperties

* lifetimeReferrer_percent_of_fee
* cashbackVestingThreshold
* countNonMemberVotes
* allowNonMemberWhitelists
* feeLiquidationThreshold

#### DynamicGlobalProperties

* recentSlotsFilled

### Added

#### Block

* delegate
* prevSignatures
* vmRoot

#### SidechainConfig

* erc20WithdrawTopic
* gasPrice

### Updated

#### OperationType

Changed operations ordinals 

#### Objects ids

* HistoricalTransfer - 1.6.
* ContractInfo - 1.9.
* ContractResult - 1.10.
* Account statistic - 2.5.

## 3.3.0 - 2019-07-11

### Changes
Replaced passwordOrWif with wif in the following methods:

* isOwnedBy
* registerAccount
* createAsset
* issueAsset
* createContract
* callContract
* generateEthAddress
* withdrawalEth
* sendTransferOperation

### Added
Added account registration by wif
Added method for account wif (active and echorand key) changing
Added random account's private key generation

### Removed
Removed ECKey and all connected features

### Tests
Removed tests with password and added required tests with wif

## 3.2.1 - 2019-06-24

### Changes

Added Extensions to CallContractOperation, CreateContractOperation, SidechainBurnOperation, SidechainIssueOperation

### Tests
Updated tests according to changed methods

## 3.2 - 2019-06-11

### Changes

* Account - removed owner Authority
* AccountOptions - removed memo
* Public keys prefix - ECHO
* Added new virtual operations to account history

### Methods
#### Added
* getAccountDeposits - returns all approved deposits, for the given account id
* getAccountWithdrawals - returns all approved withdrawals, for the given account id

### Operations
Fixed OperationType enum to actual
Removed memo from all operations
#### Added
* SidechainBurnSocketOperation (virtual)
* SidechainIssueSocketOperation (virtual)


### Objects
Fixed GlobalProperties
#### Added
* DepositEth
* WithdrawalEth
* FeeType - represent fee for operation (AssetAmount or CallContractFee)  
* CallContractFee 
#### Removed
* Memo

### Tests
Updated tests according to changed methods

## 3.1 - 2019-05-27

### Authority
Owner Authority was removed from the network
Active Authority key was changed to EdDSA (same key used in Echorand)

#### Changes

* Account - removed owner authority
* AddressKeysContainer - removed owner keychain
* AccountUpdateOperation - removed owner authority
* RegisterAccountSocketOperation - removed owner key
* SignaturesGenerator - changed EcDSA signature to EdDSA


### Framework setup
Added fee muliplier which will be used for contract operations

### Methods
#### Added 
* getBlock - get block by block number
* subscribeContract - subscribe to contract changes by contract ID
* getEthAddress - returns generated ETH address by account ID

#### Removed
* getAllContracts
* subscribeContractLogs

### Operations
Fixed OperationType enum to match current state
#### Added 
* ContractTransfetOperation
* GenerateEthAddressOperation
* WithdrawalEthOperation


### Objects
Fixed ObjectType enum to match current state
### Added 
* ContractHistory
* EthAddress

### Tests
Now we have two tests sets. The fitst is offline tests with stubs and the second is online test. Online tests are located in ECHONetworkTests target.

### Bugs
* Fixed concurrency issue
* Fixed encode/decode bytes for contract bytecode
* Fixed decode contract address from contract bytecode
* Fixed decode address from contract bytecode
* Fixed setSubscribeCallback method. Now it is called on framework launch

### Protection Levels
* SocketMessangerImp is now public
* ECHOQueue is now public

