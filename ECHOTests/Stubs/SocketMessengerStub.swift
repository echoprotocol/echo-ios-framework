//
//  SocketMessengerStub.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 23.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

import Foundation
import ECHO

enum OperationsState {
    case changePassword
    case transfer
    case issueAsset
    case createAsset
    case getContract
    case `default`
}

final class SocketMessengerStub: SocketMessenger {
    
    let operationState: OperationsState
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
    
    init(state: OperationsState = .default) {
        operationState = state
    }
    
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
        
        let response: String?
        
        switch operationState {
        case .default:
            response = getConstantResponse(request: string)
        case .changePassword:
            response = getChangePasswordResponse(request: string)
        case .transfer:
            response = getTransferResponse(request: string)
        case .issueAsset:
            response = getIssueAssetResponse(request: string)
        case .createAsset:
            response = getCreateAssetResponse(request: string)
        case .getContract:
            response = getContractResponse(request: string)
        }
    
        if let response = response {
            onText?(response)
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
    
    fileprivate func getConstantResponse(request: String) -> String? {
        
        switch request {
        case HistoryAPIRevealSocketRequestStub.request:
            revealHistoryApi = true
            return HistoryAPIRevealSocketRequestStub.response
        case AccountSocketRequestStub.request:
            return AccountSocketRequestStub.response
        case LoginRevealSocketRequestStub.request:
            login = true
            return LoginRevealSocketRequestStub.response
        case DatabaseAPIRevealSocketRequestStub.request:
            revealDatabaseApi = true
            return DatabaseAPIRevealSocketRequestStub.response
        case NetworkBroadcastAPIRevealSocketRequestStub.request:
            revealNetBroadcastsApi = true
            return NetworkBroadcastAPIRevealSocketRequestStub.response
        case NetworkNodesAPIRevealSocketRequestStub.request:
            revealNetNodesApi = true
            return NetworkNodesAPIRevealSocketRequestStub.response
        case CryptoAPIRevealSocketRequestStub.request:
            revealCryptoApi = true
            return CryptoAPIRevealSocketRequestStub.response
        case AccountHistorySocketRequestStub.request:
            return AccountHistorySocketRequestStub.response
        case AccountSocketRequestForNotificationStub.request:
            return AccountSocketRequestForNotificationStub.response
        case AccountSocketRequestForNotificationStub2.request:
            return AccountSocketRequestForNotificationStub2.response
        case AccountSocketRequestForNotificationStub3.request:
            return AccountSocketRequestForNotificationStub3.response
        case SubscribeSuccesNotificationStub.request:
            return SubscribeSuccesNotificationStub.response
        default:
            return nil
        }
    }
    
    fileprivate func parceRequest(request: String) -> (id: Int, operationType: String)? {
        
        if let json = (request.data(using: .utf8))
            .flatMap({ try? JSONSerialization.jsonObject(with: $0, options: [])}) as? [String: Any] {
            
            let id = json["id"] as? Int
            let operationType = (json["params"] as? [Any]).flatMap { $0[safe: 1] as? String }
            
            if let id = id, let operationType = operationType {
                return (id, operationType)
            }
        }
        
        return nil
    }
    
    fileprivate func getChangePasswordResponse(request: String) -> String? {

        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHodler = RevialAPISocketRequestStubHodler()
        let changePasswordHodler = ChangePasswordSocketRequestHodlerStub()

        if let revealResponse = revealHodler.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let changePasswordResponse = changePasswordHodler.response(id: tuple.id, operationType: tuple.operationType) {
            return changePasswordResponse
        }
        
        return nil
    }
    
    fileprivate func getTransferResponse(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHodler = RevialAPISocketRequestStubHodler()
        let transferHodler = TransferSocketRequestStubHodler()
        
        if let revealResponse = revealHodler.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let transferResponse = transferHodler.response(id: tuple.id, operationType: tuple.operationType) {
            return transferResponse
        }
        
        return nil
    }
    
    fileprivate func getIssueAssetResponse(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHodler = RevialAPISocketRequestStubHodler()
        let issueAssetHodler = IssueAssetSocketRequestStubHodler()
        
        if let revealResponse = revealHodler.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let issueAssetResponse = issueAssetHodler.response(id: tuple.id, operationType: tuple.operationType) {
            return issueAssetResponse
        }
        
        return nil
    }
    
    fileprivate func getCreateAssetResponse(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHodler = RevialAPISocketRequestStubHodler()
        let createAssetHodler = CreateAssetSocketRequestStubHodler()
        
        if let revealResponse = revealHodler.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let createAssetResponse = createAssetHodler.response(id: tuple.id, operationType: tuple.operationType) {
            return createAssetResponse
        }
        
        return nil
    }
    
    fileprivate func getContractResponse(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHodler = RevialAPISocketRequestStubHodler()
        let getContractHodler = GetContractInfoStubHodler()
        
        if let revealResponse = revealHodler.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let getContractResponse = getContractHodler.response(id: tuple.id, operationType: tuple.operationType) {
            return getContractResponse
        }
        
        return nil
    }

}

