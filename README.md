
# Echo-ios-framework (echo-ios-framework)

Pure Swift Echo framework for iOS mobile development. Can be used to work with accounts, transactions and contracts in Swift, and to easily obtain data from the blockchain via public apis.

## Install

This framework can be obtained through CocoaPods:
```
TODO
```

## Setup

For setup framework use this simple code:
```swift
// Create and Setup framework main class
let echo = ECHO(settings: Settings(build: {

    /** Here you can put your custom settings for our framework

        Example: 
        Custom api options which can be used
    */
    $0.apiOptions = [.accountHistory, .database, .networkBroadcast]
}))

// Start framwork. Connect to nodes and setup public apis
echo.start { (result) in

    switch result {
    case .success(let result):
        print(result)
    case .failure(let error):
        print(error)
}
```

## Usage

There are simple examples of usage framework

### Accounts

#### Login

```swift
func login() {
    echo.isOwnedBy(name: "some name", password: "some password") { (result) in
        print(result)
    }
}
```

#### Info

```swift
func getInfo() {
        
    let name = "some name"
    
    echo.getAccount(nameOrID: name) { (result) in
        print("Account \(result)")
    }
    
    echo.getBalance(nameOrID: name, asset: "1.3.1") { (result) in
        print("Balances \(result)")
    }
    
    echo.isAccountReserved(nameOrID: name) { (result) in
        print("Is reserved \(result)")
    }
    
    echo.getBalance(nameOrID: "vsharaev1", asset: nil) { (result) in
        print("Assets with balances \(result)")
    }
}
```

#### History

```swift
func getHistory() {
        
    echo.getAccountHistroy(nameOrID: "some id", startId: "1.11.0", stopId: "1.11.0", limit: 100) { (result) in
        switch result {
        case .success(let history):
            print(history)
            for element in history {
                print(element)
            }
        case .failure(let error):
            print(error)
        }
    }
}
```

#### Subscribe to account

```swift
func setSubscriber() {
        
    let name = "some name"
    
    echo.subscribeToAccount(nameOrId: name, delegate: self)
}

extension YourClass: SubscribeAccountDelegate {
    
    func didUpdateAccount(userAccount: UserAccount) {
        print("Account updated \(userAccount)")
    }
}
```

#### Change password

```swift
func changePassword() {
        
    echo.changePassword(old: "your old pass", new: "your new pass", name: "some name") { (result) in
        
        switch result {
        case .success(let success):
            print(success)
        case .failure(let error):
            print(error)
        }
    }
}
```

#### Fee for transfer

```swift
func feeForTransfer() {
        
    echo.getFeeForTransferOperation(fromNameOrId: "some name", 
                                    toNameOrId: "some name", 
                                    amount: 300, 
                                    asset: "1.3.0", 
                                    assetForFee: nil, // By default use "1.3.0" asset
                                    message: "some message") { (result) in
        switch result {
        case .success(let fee):
            print(fee)
        case .failure(let error):
            print(error)
        }
    }
}
```

#### Transfer

```swift
    echo.sendTransferOperation(fromNameOrId: "some name",
                                password: "some pass",
                               toNameOrId: "some name",
                               amount: 300,
                               asset: "1.3.0",
                               assetForFee: nil, // By default use "1.3.0" asset
                               message: "some message") { (result) in
                                    
        switch result {
        case .success(let success):
            print(success)
        case .failure(let error):
            print(error)
        }
    }
```

### Assets

#### Create asset

```swift
func createAsset() {
    
    var asset = Asset("")
    asset.symbol = "some symbol"
    asset.precision = 4
    asset.issuer = Account("some account id")
    asset.predictionMarket = false
    
    let price = Price(base: AssetAmount(amount: 1, asset: Asset("1.3.0")), quote: AssetAmount(amount: 1, asset: Asset("1.3.1")))
    
    asset.options = AssetOptions(maxSupply: 100000,
                                 marketFeePercent: 0,
                                 maxMarketFee: 0,
                                 issuerPermissions: AssetOptionIssuerPermissions.committeeFedAsset.rawValue,
                                 flags: AssetOptionIssuerPermissions.committeeFedAsset.rawValue,
                                 coreExchangeRate: price,
                                 description: "some description")
    
    echo.createAsset(nameOrId: "some name", password: "some password", asset: asset) { (result) in
        
        switch result {
        case .success(let success):
            print(success)
        case .failure(let error):
            print(error)
        }
    }
}
```

#### Issue asset

```swift
func issueAsset() {
    
    echo.issueAsset(issuerNameOrId: "some name",
                    password: "some password",
                    asset: "1.3.87",
                    amount: 1,
                    destinationIdOrName: "some name",
                    message: "Some message") { (result) in
                            
        switch result {
        case .success(let success):
            print(success)
        case .failure(let error):
            print(error)
        }
}
```

### Contracts

#### Create contract

```swift
func createContract() {
        
    let byteCode = "some bytecode"
    
    echo.createContract(registrarNameOrId: "some name",
                        password: "soma pass",
                        assetId: "1.3.0",
                        byteCode: byteCode) { (result) in
    
        switch result {
        case .success(let success):
            print(success)
        case .failure(let error):
            print(error)
        }
    }
}
```

#### Call contract

```swift
func callContract() {
        
    echo.callContract(registrarNameOrId: "some name",
                      password: "some password",
                      assetId: "1.3.0",
                      contratId: "1.16.1",
                      methodName: "incrementCounter",
                      methodParams: []) { (result) in
        
        switch result {
        case .success(let success):
            print(success)
        case .failure(let error):
            print(error)
        }
    }
}
```

#### Query contract

```swift
func queryContract() {
        
    echo.queryContract(registrarNameOrId: "some name", 
                       assetId: "1.3.0", 
                       contratId: "1.16.1", 
                       methodName: "getCount", 
                       methodParams: []) { (result) in
        
        switch result {
        case .success(let success):
            print(success)
        case .failure(let error):
            print(error)
        }
    }
}
```

