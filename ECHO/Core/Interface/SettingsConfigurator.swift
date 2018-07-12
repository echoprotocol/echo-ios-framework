//
//  SettingsConfigurator.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 12.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

class Configurator {
    var url: String?
    var socketMessenger: SocketMessenger?
    var cryproComponent: CryptoCoreComponent?
}

class Settings {
    
    let url: String
    let socketMessenger: SocketMessenger
    let cryproComponent: CryptoCoreComponent
    
    typealias BuildConfiguratorClosure = (Configurator) -> Void
    
    init(build: BuildConfiguratorClosure = {_ in }) {
        
        let configurator = Configurator()
        build(configurator)
        url = configurator.url ?? ""
        socketMessenger = configurator.socketMessenger ?? SocketMessengerImp()
        cryproComponent = configurator.cryproComponent ?? CryptoCoreComponentImp()
    }
}
