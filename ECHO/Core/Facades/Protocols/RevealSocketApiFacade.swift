//
//  RevilSocketApiFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 13.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    The interface that defines everything that is used by the API Services library
 */
protocol RevealApiFacade {
    
/**
     Constructor class for initializing APIs
     
     - Parameter socketCore: The class that sends operations to the socket
     - Parameter options: List of APIs to initialize
     - Parameter services: Services in which will be installed initialized API ids
 */
    init(socketCore: SocketCoreComponent,
         options: APIOption,
         services: RevealFacadeServices)
    
/**
     This is a function for initializing APIs
     
     - Parameter completion: Callback in which the information will return whether the revealing APIs was successful.
 */
    func revealApi(completion: @escaping Completion<Void>)
    
/**
     This function is used for closing (disconnecting) APIs
 */
    func disconnectApi()
}
