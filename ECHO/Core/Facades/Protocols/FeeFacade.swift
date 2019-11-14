//
//  FeeFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    The interface of the class that is responsible for the fee cost of the operation
 */
public protocol FeeFacade {
    
/**
     Function for evaluating the fee of transfer operation
     
     - Parameter fromNameOrId: Sender name or id
     - Parameter toNameOrId: Receiver name or id
     - Parameter amount: Amount
     - Parameter asset: Id of asset which is sent
     - Parameter assetForFee: Id of asset which is pay fee
     - Parameter completion: Callback which returns fee for operation or error
 */
    func getFeeForTransferOperation(fromNameOrId: String,
                                    toNameOrId: String,
                                    amount: UInt,
                                    asset: String,
                                    assetForFee: String?,
                                    completion: @escaping Completion<AssetAmount>)
    
/**
     Function for evaluating the fee creates contract operation
     
     - Parameter registrarNameOrId: Name or id of account that creates the contract
     - Parameter wif: WIF from account for transaction signature
     - Parameter assetId: Asset of contract
     - Parameter byteCode: Bytecode of the contract
     - Parameter supportedAssetId: If you dont want to link the contract with the specified asset
     - Parameter ethAccuracy: If true all balances passing to contract with ethereum accuracy
     - Parameter parameters: Parameters of constructor
     - Parameter completion: Callback which returns fee for create contract operation or error
 */
    func getFeeForCreateContract(registrarNameOrId: String,
                                 wif: String,
                                 assetId: String,
                                 amount: UInt?,
                                 assetForFee: String?,
                                 byteCode: String,
                                 supportedAssetId: String?,
                                 ethAccuracy: Bool,
                                 parameters: [AbiTypeValueInputModel]?,
                                 completion: @escaping Completion<AssetAmount>)
        
/**
     Function for evaluating the fee creates contract operation
     
     - Parameter registrarNameOrId: Name or id of account that creates the contract
     - Parameter wif: WIF from account for transaction signature
     - Parameter assetId: Asset of contract
     - Parameter byteCode: Full bytecode for contract creation
     - Parameter supportedAssetId: If you dont want to link the contract with the specified asset
     - Parameter ethAccuracy: If true all balances passing to contract with ethereum accuracy
     - Parameter completion: Callback which returns fee for create contract operation or error
 */
    func getFeeForCreateContract(registrarNameOrId: String,
                                 wif: String,
                                 assetId: String,
                                 amount: UInt?,
                                 assetForFee: String?,
                                 byteCode: String,
                                 supportedAssetId: String?,
                                 ethAccuracy: Bool,
                                 completion: @escaping Completion<AssetAmount>)
    
/**
     Function for evaluating the fee of call contract operation
     
     - Parameter registrarNameOrId: Name or id of account that call the contract
     - Parameter assetId: Asset of contract
     - Parameter amount: Amount
     - Parameter asset: Id of asset which is sent
     - Parameter assetForFee: Id of asset which is pay fee
     - Parameter contratId: Id of called contract
     - Parameter methodName: Name of called method
     - Parameter methodParams: Parameters of called method
     - Parameter completion: Callback which returns fee for operation or error
*/
    func getFeeForCallContractOperation(registrarNameOrId: String,
                                        assetId: String,
                                        amount: UInt?,
                                        assetForFee: String?,
                                        contratId: String,
                                        methodName: String,
                                        methodParams: [AbiTypeValueInputModel],
                                        completion: @escaping Completion<CallContractFee>)
    
/**
     Function for evaluating the fee of call contract operation
     
     - Parameter registrarNameOrId: Name or id of account that call the contract
     - Parameter assetId: Asset of contract
     - Parameter amount: Amount
     - Parameter asset: Id of asset which is sent
     - Parameter assetForFee: Id of asset which is pay fee
     - Parameter contratId: Id of called contract
     - Parameter byteCode: Code which will be execute
     - Parameter completion: Callback which returns fee for operation or error
 */
    func getFeeForCallContractOperation(registrarNameOrId: String,
                                        assetId: String,
                                        amount: UInt?,
                                        assetForFee: String?,
                                        contratId: String,
                                        byteCode: String,
                                        completion: @escaping Completion<CallContractFee>)
}
