//
//  SettingsConfigurator.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 12.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public struct APIOption: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static public let database  = APIOption(rawValue: 1 << 0)
    static public let accountHistory = APIOption(rawValue: 1 << 1)
    static public let crypto  = APIOption(rawValue: 1 << 2)
    static public let networkBroadcast  = APIOption(rawValue: 1 << 3)
    static public let networkNodes  = APIOption(rawValue: 1 << 4)
}

final public class Configurator {
    public var socketMessenger: SocketMessenger = SocketMessengerImp()
    public var cryproComponent: CryptoCoreComponent = CryptoCoreImp()
    public var apiOptions: APIOption = [.database, .accountHistory, .networkBroadcast, .crypto, .networkNodes]
    public var network: Network = Network(url: "wss://echo-devnet-node.pixelplex.io/", prefix: NetworkPrefix.echo)
}

final public class Settings {
    
    public let socketMessenger: SocketMessenger
    public let cryproComponent: CryptoCoreComponent
    public let apiOptions: APIOption
    public let network: Network

    public typealias BuildConfiguratorClosure = (Configurator) -> Void
    
    public init(build: BuildConfiguratorClosure = {_ in }) {
        
        let configurator = Configurator()
        build(configurator)
        network = configurator.network
        socketMessenger = configurator.socketMessenger
        cryproComponent = configurator.cryproComponent
        apiOptions = configurator.apiOptions
    }
    
    public static let defaultDateFormat = "yyyy-MM-dd'T'HH:mm:ss"
}

public enum NetworkPrefix: String {
    case echo = "ECHO"
    case bitshares = "GPH"
    case bitsharesTestnet = "TEST"
}

final public class Network {
    
    public let url: String
    public let prefix: NetworkPrefix
    
    public init(url: String, prefix: NetworkPrefix) {
        self.prefix = prefix
        self.url = url
    }
}
