//
//  Error.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 10.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    An enum representing either a failure with an explanatory error
 */
public enum ECHOError: Swift.Error, Equatable {
    
    /// Indicates that Encodable couldn't be encoded into Object
    case encodableMapping
    
    /// Indicates that wif or user name is not valid
    case invalidCredentials
    
    /// Indicates that wif is not valid
    case invalidWIF
    
    /// Indicates that required data is missed
    case internalError(ECHOResponseError)
    
    /// Indicates that required data is missed
    case resultNotFound
    
    /// Indicates that ulr is not valid
    case invalidUrl
    
    /// Indicates that connection is lost
    case connectionLost
    
    /// Identifies that the request takes too long
    case timeout
    
    /// Indicates that encode or decode abi failed
    case abiCoding
    
    /// Indicates that object identifier have not valid format
    case identifierFormat
    
    /// Indicates that object identifier have not valid type
    case identifier(ObjectType)

    /// Indicates that Ethereum address have not valid format or checksum
    case invalidETHAddress
    
    /// Indicates that Bitcoin address have not valid format or checksum
    case invalidBTCAddress
    
    case undefined
}
