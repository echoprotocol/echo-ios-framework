//
//  AssetsFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 04.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Encapsulates logic, associated with echo blockchain assets use cases
 */
public protocol AssetsFacade {
    
/**
     Creates asset [asset] with required parameters
 */
    func createAsset(nameOrId: String,
                     password: String,
                     asset: Asset,
                     completion: @escaping Completion<Bool>)
    
/**
     Issues [asset] from [issuerNameOrId] account to [destinationIdOrName] account
 */
    func issueAsset(issuerNameOrId: String,
                    password: String,
                    asset: String,
                    amount: String,
                    destinationIdOrName: String,
                    message: String?,
                    completion: @escaping Completion<Bool>)
    
/**
     Query list of assets by required asset symbol [lowerBound] with limit [limit]
 */
    func listAssets(lowerBound: String,
                    limit: Int,
                    completion: @escaping Completion<[Asset]>)
    
/**
     Query list of assets by it's ids [assetIds]
 */
    func getAsset(assetIds: [String],
                  completion: @escaping Completion<[Asset]>)
}
