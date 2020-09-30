//
//  BalanceObject.swift
//  ECHO
//
//  Created by Alexander Eskin on 9/30/20.
//  Copyright © 2020 PixelPlex. All rights reserved.
//

import Foundation

public struct BalanceObject: ECHOObject, Decodable {
    public var id: String
    
    public init(_ id: String) {
        self.id = id
    }
}
