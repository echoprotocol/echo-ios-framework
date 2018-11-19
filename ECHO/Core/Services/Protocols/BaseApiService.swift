//
//  BaseApiService.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 19/11/2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Base protocol for Api services, which contains common logic for service
 */
protocol BaseApiService: ApiIdentifireHolder {
    
    init(socketCore: SocketCoreComponent)
    
    /**
        Send socket operation, which not implemented in framework
     
        - Parameter operation: The operation, which need send
     */
    func sendCustomOperation(operation: CustomSocketOperation)
}

/**
    Protocol holder for api identifier
 */
protocol ApiIdentifireHolder: class {
    
    var apiIdentifire: Int { get set }
}
