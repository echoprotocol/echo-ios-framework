//
//  NoticeHandleQueueOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 8/19/20.
//  Copyright © 2020 PixelPlex. All rights reserved.
//

import Foundation

typealias NoticeHandleQueueOperationInitParams = (
    queue: ECHOQueue,
    noticeKey: String,
    noticeErrorKey: String,
    noticeHandlerKey: String
)

/**
   Operation for [ECHOQueue](ECHOQueue) whitch process notice result
*/
final class NoticeHandleQueueOperation: Operation {
    fileprivate weak var queue: ECHOQueue?
    fileprivate let noticeKey: String
    fileprivate let noticeErrorKey: String
    fileprivate let noticeHandlerKey: String
    
    required init(initParams: NoticeHandleQueueOperationInitParams) {
        self.queue = initParams.queue
        self.noticeKey = initParams.noticeKey
        self.noticeErrorKey = initParams.noticeErrorKey
        self.noticeHandlerKey = initParams.noticeHandlerKey
    }
    
    override func main() {
        super.main()
        
        if isCancelled { return }
        guard let noticeHandler: NoticeHandler = queue?.getValue(noticeHandlerKey) else { return }
        
        if let notice: ECHONotification = queue?.getValue(noticeKey) {
            guard let noticeResult = notice.params.result.first else {
                let result = Result<ECHONotification, ECHOError>(error: .encodableMapping)
                noticeHandler(result)
                return
            }
            
            let result: Result<ECHONotification, ECHOError>
            switch noticeResult {
            case .result:
                result = Result<ECHONotification, ECHOError>(value: notice)
                
            case .error(let error):
                result = Result<ECHONotification, ECHOError>(error: .internalError(error))
            }
            noticeHandler(result)
            return
        }
        
        if let noticeError: ECHOError = queue?.getValue(noticeErrorKey) {
            let result = Result<ECHONotification, ECHOError>(error: noticeError)
            noticeHandler(result)
            return
        }
    }
}
