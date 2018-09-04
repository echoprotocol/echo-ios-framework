//
//  AssetsFacadeImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 04.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public struct AssetsServices {
    var databaseService: DatabaseApiService
    var networkBroadcastService: NetworkBroadcastApiService
}

final public class AssetsFacadeImp: AssetsFacade, ECHOQueueble {
    
    var queues: [ECHOQueue]
    let services: AssetsServices
    let cryptoCore: CryptoCoreComponent
    
    public init(services: AssetsServices, cryptoCore: CryptoCoreComponent) {
        
        self.services = services
        self.cryptoCore = cryptoCore
        self.queues = [ECHOQueue]()
    }
    
    public func createAsset(name: String, password: String, asset: Asset, completion: @escaping (Result<Bool, ECHOError>) -> Void) {
        
    }
    
    public func issueAsset(issuerNameOrId: String, password: String, asset: String,
                           amount: String, destinationIdOrName: String, message: String?,
                           completion: @escaping (Result<Bool, ECHOError>) -> Void) {
        
    }
    
    public func listAssets(lowerBound: String, limit: Int, completion: @escaping (Result<[Asset], ECHOError>) -> Void) {
        
    }
    
    public func getAsset(assetIds: [String], completion: @escaping (Result<[Asset], ECHOError>) -> Void) {
        
    }    
}
