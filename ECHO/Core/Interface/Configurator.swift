//
//  Configurator.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 31.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
     A class that configures the modules used and has the default implementation.
 */

final public class Configurator {
    var socketMessenger: SocketMessenger = SocketMessengerImp()
    var cryproComponent: CryptoCoreComponent = CryptoCoreImp()
    var apiOptions: APIOption = [.database, .accountHistory, .networkBroadcast, .crypto, .networkNodes]
    var network: Network = Network(url: "wss://echo-devnet-node.pixelplex.io/", prefix: NetworkPrefix.echo)
}
