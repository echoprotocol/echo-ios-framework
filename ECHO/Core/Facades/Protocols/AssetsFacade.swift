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
     
     - Parameter nameOrId: Creator name or id
     - Parameter wif: Creator wif from account
     - Parameter asset: Asset object for create
     - Parameter sendCompletion: Callback in which the information will return whether the transaction was successful send to chain.
     - Parameter confirmNoticeHandler: Callback in which the information will return whether the transaction was confirmed or not.
*/
    func createAsset(
        nameOrId: String,
        wif: String,
        asset: Asset,
        sendCompletion: @escaping Completion<Void>,
        confirmNoticeHandler: NoticeHandler?
    )
    
/**
     Issues [asset] from [issuerNameOrId] account to [destinationIdOrName] account
     
     - Parameter issuerNameOrId: Issuer name or id
     - Parameter wif: Issuer wif from account
     - Parameter asset: Asset object for issue
     - Parameter amount: Amount for issue
     - Parameter destinationIdOrName: Issue destination name or id
     - Parameter sendCompletion: Callback in which the information will return whether the transaction was successful send to chain.
     - Parameter confirmNoticeHandler: Callback in which the information will return whether the transaction was confirmed or not.
 */
    func issueAsset(
        issuerNameOrId: String,
        wif: String,
        asset: String,
        amount: UInt,
        destinationIdOrName: String,
        sendCompletion: @escaping Completion<Void>,
        confirmNoticeHandler: NoticeHandler?
    )
    
/**
     Query list of assets by required asset symbol [lowerBound] with limit [limit]
 */
    func listAssets(
        lowerBound: String,
        limit: Int,
        completion: @escaping Completion<[Asset]>
    )
    
/**
     Query list of assets by it's ids [assetIds]
 */
    func getAsset(
        assetIds: [String],
        completion: @escaping Completion<[Asset]>
    )
}
