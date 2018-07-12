//
//  ECHO.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import SocketIO

public class ECHO {
    
    var socketCore: SocketCoreComponent

    public init() {
        let socketCore = SocketCoreComponentImp()
        socketCore.connect(toUrl: "https://testnet-walletapi.qtum.org")
        self.socketCore = socketCore
    }
}
