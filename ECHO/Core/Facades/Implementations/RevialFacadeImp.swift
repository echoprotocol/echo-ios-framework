//
//  RevialFacadeImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 13.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

class RevialFacadeImp: RevialApiFacade {
    
    var socketCore: SocketCoreComponent
    var apiOptions: APIOption
    
    required init(messanger: SocketMessenger, url: String, options: APIOption) {
        apiOptions = options
        socketCore = SocketCoreComponentImp(messanger: messanger, url: url)
    }
    
    func revilApi(completion: @escaping Completion<Bool>) {
        
        socketCore.connect(options: apiOptions) { [weak self] (result) in
            switch result {
            case .success(_):
                self?.registApi()
            case .failure(let error):
                let error = Result<Bool, ECHOError>(error: error)
                completion(error)
            }
        }
    }
    
    func registApi() {
        
    }
}
