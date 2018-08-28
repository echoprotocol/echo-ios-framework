//
//  FeeFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public protocol FeeFacade {
    func getFeeForTransferOperation(fromNameOrId: String,
                                    toNameOrId: String,
                                    amount: UInt,
                                    asset: String,
                                    completion: @escaping Completion<AssetAmount>)
}
