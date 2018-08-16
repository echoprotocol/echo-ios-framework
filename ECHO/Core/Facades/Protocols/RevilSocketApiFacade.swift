//
//  RevilSocketApiFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 13.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

protocol RevealApiFacade {
    
    init(socketCore: SocketCoreComponent,
         options: APIOption,
         services: RevealFacadeServices)
    
    func revealApi(completion: @escaping Completion<Bool>)
}
