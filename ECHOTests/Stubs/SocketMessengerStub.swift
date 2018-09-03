//
//  SocketMessengerStub.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 23.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation
import ECHO

final class SocketMessengerStub: SocketMessenger {
    
    var connectedUrl: String?
    
    var revealDatabaseApi = false
    var revealHistoryApi = false
    var revealCryptoApi = false
    var revealNetNodesApi = false
    var revealNetBroadcastsApi = false
    var login = false
    
    var connectionCount = 0
    var disconectionCount = 0
    
    var state: SocketConnectionState = .connected
    var onConnect: (() -> ())?
    var onDisconnect: (() -> ())?
    var onFailedConnect: (() -> ())?
    var onText: ((String) -> ())?
    
    func connect(toUrl: String) {
        connectedUrl = toUrl
        connectionCount += 1
        onConnect?()
    }
    
    func disconnect() {
        disconectionCount += 1
        onDisconnect?()
    }
    
    func write(_ string: String) {
        
        switch string {
        case HistoryAPIRevealSocketRequestStub.request:
            onText?(HistoryAPIRevealSocketRequestStub.response)
            revealHistoryApi = true
        case AccountSocketRequestStub.request:
            onText?(AccountSocketRequestStub.response)
        case LoginRevealSocketRequestStub.request:
            onText?(LoginRevealSocketRequestStub.response)
            login = true
        case DatabaseAPIRevealSocketRequestStub.request:
            onText?(DatabaseAPIRevealSocketRequestStub.response)
            revealDatabaseApi = true
        case NetworkBroadcastAPIRevealSocketRequestStub.request:
            onText?(NetworkBroadcastAPIRevealSocketRequestStub.response)
            revealNetBroadcastsApi = true
        case NetworkNodesAPIRevealSocketRequestStub.request:
            onText?(NetworkNodesAPIRevealSocketRequestStub.response)
            revealNetNodesApi = true
        case CryptoAPIRevealSocketRequestStub.request:
            onText?(CryptoAPIRevealSocketRequestStub.response)
            revealCryptoApi = true
        case AccountHistorySocketRequestStub.request:
            onText?(AccountHistorySocketRequestStub.response)
        case AccountSocketRequestForNotificationStub.request:
            onText?(AccountSocketRequestForNotificationStub.response)
        case AccountSocketRequestForNotificationStub2.request:
            onText?(AccountSocketRequestForNotificationStub2.response)
        case AccountSocketRequestForNotificationStub3.request:
            onText?(AccountSocketRequestForNotificationStub3.response)
        case SubscribeSuccesNotificationStub.request:
            onText?(SubscribeSuccesNotificationStub.response)
        case TransferAccountsSocketRequestStub.request:
            onText?(TransferAccountsSocketRequestStub.response)
        case TransferRequredFeeSocketRequestStub.request:
            onText?(TransferRequredFeeSocketRequestStub.response)
        case TransferChainIdSocketRequestStub.request:
            onText?(TransferChainIdSocketRequestStub.response)
        case TransferGlobalPropertiesSocketRequestStub.request:
            onText?(TransferGlobalPropertiesSocketRequestStub.response)
        case TransferResultSocketRequestStub.request:
            onText?(TransferResultSocketRequestStub.response)
        default:
            break
        }        
    }
    
    func makeUserAccountTransferChangeEvent() {
        onText?(ChangePasswordEventNotificationStub.response1)
        onText?(ChangePasswordEventNotificationStub.response2)
        onText?(ChangePasswordEventNotificationStub.response3)
    }
    
    func makeUserAccountChangePasswordEvent() {
        onText?(TransactionEventEventNotificationStub.response1)
        onText?(TransactionEventEventNotificationStub.response2)
        onText?(TransactionEventEventNotificationStub.response3)
    }
}

