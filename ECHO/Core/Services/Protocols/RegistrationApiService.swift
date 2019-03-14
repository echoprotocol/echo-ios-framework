//
//  RegistrationApiService.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 15/01/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/**
 Encapsulates logic, associated with registration API
 
 - Note: [Echo registration API](http://wiki.echo-dev.io/developers/apis/registration-api/)
 */
protocol RegistrationApiService: BaseApiService {
    
    /**
     Register new account in blockchain
     
     - Parameter name: The name of new account
     - Parameter ownerKey: The ECDSA key used for owner role
     - Parameter activeKey: The ECDSA key used for active role
     - Parameter memoKey: The ECDSA key used for memo role
     - Parameter echorandKey: The ed25519 key used for echorand
     - Parameter completion: Callback which returns bool result or error
     */
    func registerAccount(name: String,
                         ownerKey: String,
                         activeKey: String,
                         memoKey: String,
                         echorandKey: String,
                         completion: @escaping Completion<Bool>)
}
