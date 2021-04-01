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

public extension NoticeEventDelegate where Self: ECHOQueueble {
    func didReceiveNotification(notification: ECHONotification) {
        for queue in queues.values {
            if let queueTransferOperationId: Int = queue.getValue(EchoQueueMainKeys.operationId.rawValue),
                queueTransferOperationId == notification.params.id {
                queue.saveValue(notification, forKey: EchoQueueMainKeys.notice.rawValue)
                startNextOperationIfNeedFor(queue)
            }
        }
    }
    
    func didAllNoticesLost() {
        for queue in queues.values {
            queue.saveValue(ECHOError.connectionLost, forKey: EchoQueueMainKeys.noticeError.rawValue)
            startNextOperationIfNeedFor(queue)
        }
    }
}

public protocol NoticeEventDelegateHandler: class {
    var delegate: NoticeEventDelegate? { get set }
}

public protocol NoticeActionHandler {
    
    func actionReceiveNotice(notification: ECHONotification)
    func actionAllNoticesLost()
}

public protocol NoticeEventProxy: NoticeActionHandler, NoticeEventDelegateHandler { }
