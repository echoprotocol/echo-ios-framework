//
//  Settings.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 31.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    The class used to initialize the library. Sets the implementation of modules.
 */
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
