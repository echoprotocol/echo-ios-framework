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

import Foundation

final public class Configurator {
    public var workingQueue: DispatchQueue = DispatchQueue.main
    public var socketMessenger: SocketMessenger = SocketMessengerImp()
    public var cryproComponent: CryptoCoreComponent = CryptoCoreImp()
    public var abiCoderComponent: AbiCoder = AbiCoderImp(argumentCoder: AbiArgumentCoderImp())
    public var apiOptions: APIOption = [.database, .accountHistory, .networkBroadcast, .crypto, .networkNodes, .registration]
    public var network: ECHONetwork = ECHONetwork(url: "ws://195.201.164.54:63101/",
                                                  prefix: ECHONetworkPrefix.echo,
                                                  echorandPrefix: .det)
}
