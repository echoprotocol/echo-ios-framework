//
//  ECHO.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public class ECHO {
    
    var revilFacade: RevialApiFacade

    public init(settings: Settings) {
        revilFacade = RevialFacadeImp(messanger: settings.socketMessenger, url: settings.url, options: settings.apiOptions)
    }
    
    public func start(completion: @escaping Completion<Bool>) {
        revilFacade.revilApi(completion: completion)
    }
}
