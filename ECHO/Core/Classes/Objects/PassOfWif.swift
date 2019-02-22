//
//  PassOfWif.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 22/02/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

/*
    Enum that present private data type for library methods.
    It can be password for user or WIF of private key
 */
public enum PassOrWif {
    case password(String)
    case wif(String)
}
