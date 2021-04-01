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
    Get PoW task to register account
    
    - Parameter completion: Callback which returns an [RegistrationTask](RegistrationTask) or error
    */
    func requestRegistrationTask(completion: @escaping Completion<RegistrationTask>)
    
    /**
    Submit PoW task solution to register account
    
    - Parameter name: The name of new account
    - Parameter activeKey: The ECDSA key used for active role
    - Parameter echorandKey: The ed25519 key used for echorand
    - Parameter evmAddress: EVM address that will be assosiated with account
    - Parameter nonce: Used for verification of pow algorithm
    - Parameter randNum: Used as salt for sha256 and id for request_registration_task query
    - Parameter completion: Callback which returns bool result or error
    - Returns: ID of operation
    */
    func submitRegistrationSolution(name: String,
                                    activeKey: String,
                                    echorandKey: String,
                                    evmAddress: String?,
                                    nonce: UInt,
                                    randNum: UInt,
                                    completion: @escaping Completion<Bool>) -> Int
}
