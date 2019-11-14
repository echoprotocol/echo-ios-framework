//
//  NoticeEventProxy.swift
//  ECHO
//
//  Created by Fedorenko Nikita on 11/19/18.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

public protocol NoticeEventDelegate: class {
    func didReceiveNotification(notification: ECHONotification)
    func didAllNoticesLost()
}

public protocol NoticeEventDelegateHandler: class {
    var delegate: NoticeEventDelegate? { get set }
}

public protocol NoticeActionHandler {
    
    func actionReceiveNotice(notification: ECHONotification)
    func actionAllNoticesLost()
}

public protocol NoticeEventProxy: NoticeActionHandler, NoticeEventDelegateHandler { }
