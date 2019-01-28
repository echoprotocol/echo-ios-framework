//
//  API.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 12.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    The enum that represent netwotk API's.
 
    ## API ##
    1. Database API
    2. Account History API
    3. Crypto API
    4. Network Broadcast API
    5. Network Nodes API
 */
enum API {
    case database
    case accountHistory
    case crypto
    case networkBroadcast
    case networkNodes
    case registration
}

/**
     The class that is used by the API library.
     
     ## API ##
     1. Database API
     2. Account History API
     3. Crypto API
     4. Network Broadcast API
     5. Network Nodes API
*/
public struct APIOption: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    static public let database  = APIOption(rawValue: 1 << 0)
    static public let accountHistory = APIOption(rawValue: 1 << 1)
    static public let crypto  = APIOption(rawValue: 1 << 2)
    static public let networkBroadcast  = APIOption(rawValue: 1 << 3)
    static public let networkNodes  = APIOption(rawValue: 1 << 4)
    static public let registration  = APIOption(rawValue: 1 << 5)
}
