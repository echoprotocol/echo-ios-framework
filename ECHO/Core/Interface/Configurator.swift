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
    public var socketMessenger: SocketMessenger = SocketMessengerImp()
    public var cryproComponent: CryptoCoreComponent = CryptoCoreImp()
    public var apiOptions: APIOption = [.database, .accountHistory, .networkBroadcast, .crypto, .networkNodes]
    public var network: Network = Network(url: "wss://echo-devnet-node.pixelplex.io/", prefix: NetworkPrefix.echo)
}
