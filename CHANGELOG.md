# CHANGELOG

## 3.2 - 2017-06-11

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

## 3.1 - 2017-05-27

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

