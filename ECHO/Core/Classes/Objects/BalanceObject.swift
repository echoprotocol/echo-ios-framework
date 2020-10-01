//
//  BalanceObject.swift
//  ECHO
//
//  Created by Alexander Eskin on 9/30/20.
//  Copyright © 2020 PixelPlex. All rights reserved.
//

import Foundation

public struct BalanceObject: ECHOObject, Decodable {
    enum BalanceObjectKeys: String, CodingKey {
        case id
        case ownerKey = "owner"
        case balance
        case lastClaimDate = "last_claim_date"
        case extensions
    }
    
    public var id: String
    public var ownerKey: String?
    public var balance: AssetAmount?
    public var lastClaimDate: Date?
    public let extensions = Extensions()
    
    public init(_ id: String) {
        self.id = id
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: BalanceObjectKeys.self)
        id = try values.decode(String.self, forKey: .id)
        ownerKey = try values.decode(String.self, forKey: .ownerKey)
        balance = try values.decode(AssetAmount.self, forKey: .balance)
        
        let lastClaimDateString = try values.decode(String.self, forKey: .lastClaimDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Settings.defaultDateFormat
        dateFormatter.locale = Locale(identifier: Settings.localeIdentifier)
        lastClaimDate = dateFormatter.date(from: lastClaimDateString)
    }
}
