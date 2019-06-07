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
    public var network: ECHONetwork = ECHONetwork(url: "wss://devnet.echo-dev.io/ws",
                                                  prefix: ECHONetworkPrefix.echo,
                                                  echorandPrefix: .echo)
    public var callContractFeeMultiplier: UInt = 1
}
