//
//  SettingsConfigurator.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 12.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct APIOption: OptionSet {
    
    let rawValue: Int
    
    static let database  = APIOption(rawValue: 1 << 0)
    static let accountHistory = APIOption(rawValue: 1 << 1)
    static let crypto  = APIOption(rawValue: 1 << 2)
    static let networkBroadcast  = APIOption(rawValue: 1 << 3)
    static let networkNodes  = APIOption(rawValue: 1 << 4)
}

class Configurator {
    var url: String = ""
    var socketMessenger: SocketMessenger = SocketMessengerImp() 
    var cryproComponent: CryptoCoreComponent = CryptoCoreComponentImp()
    var apiOptions: APIOption = [.database, .accountHistory, .crypto, .networkBroadcast, .networkNodes]
}

public class Settings {
    
    let url: String
    let socketMessenger: SocketMessenger
    let cryproComponent: CryptoCoreComponent
    let apiOptions: APIOption

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
