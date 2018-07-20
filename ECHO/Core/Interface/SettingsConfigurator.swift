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

public class Configurator {
    public var url: String = "wss://node.testnet.bitshares.eu/"
    public var socketMessenger: SocketMessenger = SocketMessengerImp()
    public var cryproComponent: CryptoCoreComponent = CryptoCoreComponentImp()
    public var apiOptions: APIOption = [.database, .accountHistory, .crypto, .networkBroadcast, .networkNodes]
}

public class Settings {
    
    public let url: String
    public let socketMessenger: SocketMessenger
    public let cryproComponent: CryptoCoreComponent
    public let apiOptions: APIOption

    public typealias BuildConfiguratorClosure = (Configurator) -> Void
    
    public init(build: BuildConfiguratorClosure = {_ in }) {
        
        let configurator = Configurator()
        build(configurator)
        url = configurator.url
        socketMessenger = configurator.socketMessenger
        cryproComponent = configurator.cryproComponent
        apiOptions = configurator.apiOptions
    }
}

class ServiceLocator {
    
    private var registry: [String: Any] = [:]
    
    func registerService<T>(service: T, path: String = "") {
        let key = "\(T.self)" + path
        registry[key] = service
    }
    
    func tryGetService<T>(path: String = "") -> T? {
        let key = "\(T.self)" + path
        return registry[key] as? T
    }
}