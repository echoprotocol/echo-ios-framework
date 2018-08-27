//
//  Error.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public enum ECHOError: Swift.Error {
    
    /// Indicates that Encodable couldn't be encoded into Object
    case encodableMapping
    
    /// Indicates that password or user name is not valid
    case invalidCredentials
    
    /// Indicates that required data is missed
    case internalError(String)
    
    /// Indicates that required data is missed
    case resultNotFound

    case undefined
}
