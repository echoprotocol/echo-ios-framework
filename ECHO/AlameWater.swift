//
//  AlameWater.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 09.07.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import UIKit
import BitcoinKit

public protocol AlamoWaterProtocol: class {
    func didCallHello()
}

open class AlamoWater: NSObject {
    
    public static let shared = AlamoWater()
    
    public weak var delegate: AlamoWaterProtocol?
    
    open func hello() {
        print("WithBitcoinKit")
        AlamoWater.shared.delegate?.didCallHello()
    }
}
