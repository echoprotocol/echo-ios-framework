//
//  FrozenBalanceObject.swift
//  ECHO
//
//  Created by Alexander Eskin on 9/30/20.
//  Copyright © 2020 PixelPlex. All rights reserved.
//

import Foundation

public struct FrozenBalanceObject: ECHOObject, Decodable {
    enum FrozenBalanceObjectKeys: String, CodingKey {
        case id
        case owner
        case balance
        case multiplier
        case unfreezeTime = "unfreeze_time"
        case extensions
    }
    
    public var id: String
    public var owner: Account?
    public var balance: AssetAmount?
    public var multiplier: Int?
    public var unfreezeTime: Date?
    public let extensions = Extensions()
    
    public init(_ id: String) {
        self.id = id
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: FrozenBalanceObjectKeys.self)
        id = try values.decode(String.self, forKey: .id)
        
        let ownerID = try values.decode(String.self, forKey: .owner)
        owner = Account(ownerID)
        
        balance = try values.decode(AssetAmount.self, forKey: .balance)
        multiplier = try values.decode(Int.self, forKey: .multiplier)
        
        let unfreezeTimeString = try values.decode(String.self, forKey: .unfreezeTime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Settings.defaultDateFormat
        dateFormatter.locale = Locale(identifier: Settings.localeIdentifier)
        unfreezeTime = dateFormatter.date(from: unfreezeTimeString)
    }
}
