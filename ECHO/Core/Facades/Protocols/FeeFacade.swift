//
//  FeeFacade.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

protocol FeeFacade {
    func getFeeForTransferOperation(fromNameOrId: String,
                                    toNemOrId: String,
                                    asset: String,
                                    completion: Completion<String>)
}
