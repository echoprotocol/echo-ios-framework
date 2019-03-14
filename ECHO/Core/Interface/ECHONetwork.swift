//
//  Network.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 31.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Options that configures network parameters. Indicates the prefix that is used when generating addresses.
     ````
     case echo = "ECHO"
     case bitshares = "GPH"
     case bitsharesTestnet = "TEST"
     ````
 */
public enum ECHONetworkPrefix: String {
    /// The prefix that is used for ECHO
    case echo = "ECHO"
    
    /// The prefix that is used for Bitshares
    case bitshares = "GPH"
    
    /// The prefix that is used for testnet
    case bitsharesTestnet = "TEST"
}

/**
    Options that configures network parameters. Indicates the prefix that is used when generating addresses for echorand.
    ````
    case det = "DET"
    ````
 */
public enum EchorandPrefix: String {
    /// The prefix that is used for default echorand
    case det = "DET"
}

/**
    Class of network prefix configuration parameters
    - Parameter firstname: The first part of the full name.
    - Parameter lastname: The last part of the fullname.
 */
final public class ECHONetwork {
    
    public let url: String
    public let prefix: ECHONetworkPrefix
    public let echorandPrefix: EchorandPrefix
    
/**
     A contractor that specifies network parameters.
     - Parameter url: Socket URL
     - Parameter prefix: Prefix for addresses
 */
    public init(url: String, prefix: ECHONetworkPrefix, echorandPrefix: EchorandPrefix) {
        self.prefix = prefix
        self.url = url
        self.echorandPrefix = echorandPrefix
    }
}
