//
//  CustomOperationsFacade.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 19/11/2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    The interface of the class that allows you to send custom operations to network.
 */
protocol CustomOperationsFacade {
    
    /**
        Function for send custom operation for specific API
     
        - Parameter operation: Operation to send
        - Parameter specificAPI: Specific API to send operation
     */
    func sendCustomOperation(operation: CustomSocketOperation, for specificAPI: API)
}
