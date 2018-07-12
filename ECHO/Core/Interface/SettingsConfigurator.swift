//
//  SettingsConfigurator.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 12.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct APIOption : OptionSet {
    let rawValue: Int
    
    static let firstOption  = APIOption(rawValue: 1 << 0)
    static let secondOption = APIOption(rawValue: 1 << 1)
    static let thirdOption  = APIOption(rawValue: 1 << 2)
}

class Configurator {
    var url: String = ""
    var socketMessenger: SocketMessenger = SocketMessengerImp()
    var cryproComponent: CryptoCoreComponent = CryptoCoreComponentImp()
    var apiOptions: APIOption = [.firstOption,.secondOption,.thirdOption]
}

class Settings {
    
    let url: String
    let socketMessenger: SocketMessenger
    let cryproComponent: CryptoCoreComponent
    let apiOptions: APIOption?

    typealias BuildConfiguratorClosure = (Configurator) -> Void
    
    init(build: BuildConfiguratorClosure = {_ in }) {
        
        let configurator = Configurator()
        build(configurator)
        url = configurator.url
        socketMessenger = configurator.socketMessenger
        cryproComponent = configurator.cryproComponent
        apiOptions = configurator.apiOptions
    }
}
