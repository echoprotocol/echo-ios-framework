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
     - Parameter activeKey: The ECDSA key used for active role
     - Parameter echorandKey: The ed25519 key used for echorand
     - Parameter completion: Callback which returns bool result or error
     - Returns: ID of operation
     */
    func registerAccount(name: String,
                         activeKey: String,
                         echorandKey: String,
                         completion: @escaping Completion<Bool>) -> Int
    
    /**
    Get PoW task to register account
    
    - Parameter completion: Callback which returns an [RegistrationTask](RegistrationTask) or error
    */
    func requestRegistrationTask(completion: @escaping Completion<RegistrationTask>)
    
    /**
    Submit PoW task solution to register account
    
    - Parameter name: The name of new account
    - Parameter activeKey: The ECDSA key used for active role
    - Parameter echorandKey: The ed25519 key used for echorand
    - Parameter nonce: Used for verification of pow algorithm
    - Parameter randNum: Used as salt for sha256 and id for request_registration_task query
    - Parameter completion: Callback which returns bool result or error
    - Returns: ID of operation
    */
    func submitRegistrationSolution(name: String,
                                    activeKey: String,
                                    echorandKey: String,
                                    nonce: UInt,
                                    randNum: UInt,
                                    completion: @escaping Completion<Bool>) -> Int
}
