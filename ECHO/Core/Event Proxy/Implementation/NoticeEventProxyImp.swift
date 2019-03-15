//
//  NoticeEventProxyImp.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11/19/18.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation

public final class NoticeEventProxyImp: NoticeEventProxy {
    
    public weak var delegate: NoticeEventDelegate? {
        didSet {
            delegates.addObject(delegate)
        }
    }
    
    fileprivate var delegates = NSPointerArray.weakObjects()
    
    public func actionReceiveNotice(notification: ECHONotification) {
        delegates.compact()
        
        for index in 0..<delegates.count {
            
            if let delegate = delegates.object(at: index) as? NoticeEventDelegate {
                delegate.didReceiveNotification(notification: notification)
            }
        }
    }
}
