//
//  WaitQueueOperation.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 8/19/20.
//  Copyright © 2020 PixelPlex. All rights reserved.
//

import Foundation

typealias WaitQueueOperationInitParams = (
    queue: ECHOQueue,
    noticeKey: String,
    noticeErrorKey: String
)

/**
   Operation for [ECHOQueue](ECHOQueue) whitch stops queue for waiting notice if it hasn't been handled yet
*/
final class WaitQueueOperation: Operation {
    fileprivate weak var queue: ECHOQueue?
    fileprivate let noticeKey: String
    fileprivate let noticeErrorKey: String
    
    var isWaiting: Bool
    
    required init(initParams: WaitQueueOperationInitParams) {
        self.queue = initParams.queue
        self.noticeKey = initParams.noticeKey
        self.noticeErrorKey = initParams.noticeErrorKey
        self.isWaiting = false
    }
    
    override func main() {
        super.main()
        
        if isCancelled { return }
        let notice: ECHONotification? = queue?.getValue(noticeKey)
        let noticeError: ECHOError? = queue?.getValue(noticeKey)
        if notice != nil { return }
        if noticeError != nil { return }
        
        isWaiting = true
        queue?.waitStartNextOperation()
    }
    
    func stopWaiting() {
        if isWaiting {
            queue?.startNextOperation()
        }
        isWaiting = false
    }
}
