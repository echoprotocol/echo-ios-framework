# Echo-ios-framework (echo-ios-framework)

Pure Swift Echo framework for iOS mobile development. Can be used to work with accounts, transactions and contracts in Swift, and to easily obtain data from the blockchain via public apis.

## Install

This framework can be obtained through CocoaPods:
```
pod 'ECHO', :git => 'https://github.com/echoprotocol/echo-ios-framework.git'
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
    echo.isOwnedBy(name: "some name", wif: "some wif") { (result) in
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
        print("Balance \(result)")
    }

    echo.getBalance(nameOrID: name, asset: nil) { (result) in
        print("Assets with balances \(result)")
    }

    echo.isAccountReserved(nameOrID: name) { (result) in
        print("Is reserved \(result)")
    }
}
```

#### History

```swift
func getHistory() {

    echo.getAccountHistroy(nameOrID: "some ID", 
                           startId: "1.11.0", 
                           stopId: "1.11.0", 
                           limit: 100) { (result) in
    
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

#### Change keys

```swift
func changeKeys() {

    echo.changeKeys(oldWIF: "your old wif", newWIF: "your new wif", name: "some name") { (result) in

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
                                    assetForFee: nil) { (result) in
                                    
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

funс transfer() {

    echo.sendTransferOperation(fromNameOrId: "some name",
                               wif: "some wif",
                               toNameOrId: "some name",
                               amount: 300,
                               asset: "1.3.0",
                               assetForFee: nil,
                               completion: { (result) in

        switch result {
        case .success(let success):
            print(success)
        case .failure(let error):
            print(error)
        }
    }, noticeHandler: { notice in
        print(notice)
    })
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

    let price = Price(base: AssetAmount(amount: 1, asset: Asset("1.3.0")), 
                      quote: AssetAmount(amount: 1, asset: Asset("1.3.1")))

    asset.options = AssetOptions(maxSupply: 100000,
                                 marketFeePercent: 0,
                                 maxMarketFee: 0,
                                 issuerPermissions: AssetOptionIssuerPermissions.committeeFedAsset.rawValue,
                                 flags: AssetOptionIssuerPermissions.committeeFedAsset.rawValue,
                                 coreExchangeRate: price,
                                 description: "some description")

    echo.createAsset(nameOrId: "some name", 
                     wif: "some wif", 
                     asset: asset) { (result) in

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
                    wif: "some wif",
                    asset: "1.3.87",
                    amount: 1,
                    destinationIdOrName: "some name") { (result) in

        switch result {
        case .success(let success):
            print(success)
        case .failure(let error):
            print(error)
        }
    }
}
```

### Contracts

#### Create contract

```swift
func createContract() {

    let byteCode = "some bytecode"

    echo.createContract(registrarNameOrId: "some name",
                        wif: "some wif",
                        assetId: "1.3.0",
                        amount: nil,
                        assetForFee: nil,
                        byteCode: byteCode,
                        supportedAssetId: nil,
                        ethAccuracy: nil,
                        parameters: nil,
                        completion: { (result) in

        switch result {
        case .success(let success):
            print(success)
        case .failure(let error):
            print(error)
        }
    }, noticeHandler: { notice in
        print(notice)
    })
}
```

#### Call contract

```swift
func callContract() {

    echo.callContract(registrarNameOrId: "some name",
                      wif: "some wif",
                      assetId: "1.3.0",
                      assetForFee: nil,
                      contratId: "1.16.1",
                      methodName: "some name",
                      methodParams: [],
                      completion: { (result) in

        switch result {
        case .success(let success):
            print(success)
        case .failure(let error):
            print(error)
        }
    }, noticeHandler: { (notice) in
        print(notice)
    })
}
```

#### Query contract

```swift
func queryContract() {

    echo.queryContract(registrarNameOrId: "some name", 
                       assetId: "1.3.0", 
                       contratId: "1.16.1", 
                       methodName: "some name", 
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
