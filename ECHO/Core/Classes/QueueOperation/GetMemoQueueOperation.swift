//
//  GetMemoQueueOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 06.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

typealias GetMemoQueueOperationInitParams = (queue: ECHOQueue,
                                             cryptoCore: CryptoCoreComponent,
                                             message: String?,
                                             saveKey: String,
                                             passwordOrWif: PassOrWif,
                                             networkPrefix: String,
                                             fromAccountKey: String,
                                             toAccountKey: String)

/**
    Operation for [ECHOQueue](ECHOQueue) whitch create and save memo
 
    - Save [Memo](Memo)
 */
final class GetMemoQueueOperation<T>: Operation where T: Any {
    
    fileprivate weak var queue: ECHOQueue?
    fileprivate weak var cryptoCore: CryptoCoreComponent?
    fileprivate let message: String?
    fileprivate let saveKey: String
    fileprivate let passwordOrWif: PassOrWif
    fileprivate let networkPrefix: String
    fileprivate let fromAccountKey: String
    fileprivate let toAccountKey: String
    fileprivate let completion: Completion<T>
    
    required init(initParams: GetMemoQueueOperationInitParams, completion: @escaping Completion<T>) {
        
        self.queue = initParams.queue
        self.cryptoCore = initParams.cryptoCore
        self.message = initParams.message
        self.saveKey = initParams.saveKey
        self.passwordOrWif = initParams.passwordOrWif
        self.networkPrefix = initParams.networkPrefix
        self.fromAccountKey = initParams.fromAccountKey
        self.toAccountKey = initParams.toAccountKey
        self.completion = completion
    }
    
    override func main() {
        super.main()
        
        if isCancelled { return }
        
        guard let message = message,
              let fromAccount: Account = queue?.getValue(fromAccountKey),
              let toAccount: Account = queue?.getValue(toAccountKey),
              let fromMemoKeyString = fromAccount.options?.memoKey,
              let toMemoKeyString = toAccount.options?.memoKey,
              let cryptoCore = cryptoCore,
              let name = fromAccount.name else {
                    
            queue?.saveValue(Memo(), forKey: saveKey)
            return
        }
        
        var keysContrainer: AddressKeysContainer?
        switch passwordOrWif {
        case .password(let pass):
            keysContrainer = AddressKeysContainer(login: name, password: pass, core: cryptoCore)
        case .wif(let wif):
            keysContrainer = AddressKeysContainer(wif: wif, core: cryptoCore)
        }
        
        guard let contrainer = keysContrainer else {
                                                            
            queue?.cancelAllOperations()
            let result = Result<T, ECHOError>(error: ECHOError.invalidCredentials)
            completion(result)
            return
        }
        
        let fromPublicKey = cryptoCore.getPublicKeyFromAddress(fromMemoKeyString, networkPrefix: networkPrefix)
        let toPublicKey = cryptoCore.getPublicKeyFromAddress(toMemoKeyString, networkPrefix: networkPrefix)
        
        let nonce = UInt(0)
        let byteMessage = cryptoCore.encryptMessage(privateKey: contrainer.memoKeychain.raw,
                                                    publicKey: toPublicKey,
                                                    nonce: String(format: "%llu", nonce),
                                                    message: message)
        
        let memo = Memo(source: Address(fromMemoKeyString, data: fromPublicKey),
                        destination: Address(toMemoKeyString, data: toPublicKey),
                        nonce: nonce,
                        byteMessage: byteMessage.hex)
        
        queue?.saveValue(memo, forKey: saveKey)
    }
}
