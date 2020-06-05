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
    case reveal
    case changePassword
    case getAccount
    case transfer
    case issueAsset
    case createAsset
    case getContract
    case createContract
    case queryContract
    case callContract
    case subscribeToAccount
    case subscribeToConsractLogs
    case getBlock
    case createEthAddress
    case getEthAddress
    case withdrawEth
    case getAccountDeposits
    case getAccountWithdrawals
}

final class SocketMessengerStub: SocketMessenger {
    
    var callbackQueue: DispatchQueue
    let operationState: OperationsState
    var connectedUrl: String?
    
    var revealDatabaseApi = false
    var revealHistoryApi = false
    var revealCryptoApi = false
    var revealNetNodesApi = false
    var revealNetBroadcastsApi = false
    var registrationApi = false
    var login = false
    
    var connectionCount = 0
    var disconectionCount = 0
    
    var state: SocketConnectionState = .connected
    var onConnect: (() -> ())?
    var onDisconnect: (() -> ())?
    var onFailedConnect: (() -> ())?
    var onText: ((String) -> ())?
    
    init(state: OperationsState) {
        operationState = state
        callbackQueue = DispatchQueue(label: "SocketMessengerStub")
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
        case .reveal:
            response = getRevealResponse(request: string)
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
        case .createContract:
            response = getCreateContractResponse(request: string)
        case .queryContract:
            response = getQueryContractResponse(request: string)
        case .callContract:
            response = getCallContractResponse(request: string)
        case .subscribeToAccount:
            response = getSubscribeResponse(request: string)
        case .getAccount:
            response = getAccountResponse(request: string)
        case .subscribeToConsractLogs:
            response = getSubscribeToConstractLogsResponse(request: string)
        case .getBlock:
            response = getGetBlockResponce(request: string)
        case .createEthAddress:
            response = getCreateEthAddressRespone(request: string)
        case .getEthAddress:
            response = getEthAddressRespone(request: string)
        case .withdrawEth:
            response = getWithdrawEthRespone(request: string)
        case .getAccountDeposits:
            response = getAccountDepositsRespone(request: string)
        case .getAccountWithdrawals:
            response = getAccountWithdrawalsRespone(request: string)
        }
    
        if let response = response {
            onText?(response)
        } else {
            let response = getErrorResponse(request: string)
            onText?(response)
        }
    }
    
    func makeUserAccountTransferChangeEvent() {
        onText?(TransactionEventEventNotificationStub.response1)
        onText?(TransactionEventEventNotificationStub.response2)
    }
    
    func makeContractLogCreateEvent() {
        onText?(ContractLogsEventNotificationStub.response1)
        onText?(ContractLogsEventNotificationStub.response2)
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
        
        let revealHolder = RevealAPISocketStubsHolder()
        let changePasswordHodler = ChangePasswordSocketRequestStubHodler()

        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let changePasswordResponse = changePasswordHodler.response(id: tuple.id, operationType: tuple.operationType) {
            return changePasswordResponse
        }
        
        return nil
    }
    
    fileprivate func getErrorResponse(request: String) -> String {
        
        guard let tuple = parceRequest(request: request) else {
            return ""
        }
        
        let error = ErrorSocketRequestStub.getError(id: String(tuple.id), request: request)
        return error
    }
    
    fileprivate func getTransferResponse(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHolder = RevealAPISocketStubsHolder()
        let transferHodler = TransferSocketRequestStubHodler()
        
        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
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
        
        let revealHolder = RevealAPISocketStubsHolder()
        let issueAssetHodler = IssueAssetSocketRequestStubHodler()
        
        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
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
        
        let revealHolder = RevealAPISocketStubsHolder()
        let createAssetHodler = CreateAssetSocketRequestStubHodler()
        
        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
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
        
        let revealHolder = RevealAPISocketStubsHolder()
        let getContractHodler = GetContractInfoStubHodler()
        
        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let getContractResponse = getContractHodler.response(id: tuple.id, operationType: tuple.operationType) {
            return getContractResponse
        }
        
        return nil
    }
    
    fileprivate func getCreateContractResponse(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHolder = RevealAPISocketStubsHolder()
        let createContractHodler = CreateContractInfoStubHolder()
        
        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let createContractResponse = createContractHodler.response(id: tuple.id, operationType: tuple.operationType) {
            return createContractResponse
        }
        
        return nil
    }
    
    fileprivate func getQueryContractResponse(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHolder = RevealAPISocketStubsHolder()
        let queryContractHodler = QueryContractStubHolder()
        
        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let queryContractResponse = queryContractHodler.response(id: tuple.id, operationType: tuple.operationType) {
            return queryContractResponse
        }
        
        return nil
    }
    
    fileprivate func getCallContractResponse(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHolder = RevealAPISocketStubsHolder()
        let callContractHodler = CallContractStubHolder()
        
        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let callContractResponse = callContractHodler.response(id: tuple.id, operationType: tuple.operationType) {
            return callContractResponse
        }
        
        return nil
    }
    
    fileprivate func getSubscribeResponse(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHolder = RevealAPISocketStubsHolder()
        let stubHolder = SubscribeToAccountStubHodler()
        
        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let response = stubHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return response
        }
        
        return nil
    }
    
    fileprivate func getSubscribeToConstractLogsResponse(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHolder = RevealAPISocketStubsHolder()
        let stubHolder = SubscribeToAccountStubHodler()
        
        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let response = stubHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return response
        }
        
        return nil
        
    }
    
    fileprivate func getGetBlockResponce(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHolder = RevealAPISocketStubsHolder()
        let requestStub = GetBlockSocketRequestStub()
        
        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if tuple.operationType == requestStub.operationType {
            return requestStub.createResponce(id: tuple.id)
        }
        
        return nil
    }
    
    fileprivate func getRevealResponse(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHolder = RevealAPISocketStubsHolder()
        
        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
            
            switch tuple.operationType {
            case "crypto":
                revealCryptoApi = true
            case "network_node":
                revealNetNodesApi = true
            case "network_broadcast":
                revealNetBroadcastsApi = true
            case "database":
                revealDatabaseApi = true
            case "history":
                revealHistoryApi = true
            case "login":
                login = true
            default:
                break
            }
            
            return revealResponse
        }
        
        return nil
    }
    
    fileprivate func getAccountResponse(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHolder = RevealAPISocketStubsHolder()
        let stubHolder = GetAccountStubHolder()
        
        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let response = stubHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return response
        }
        
        return nil
    }
    
    fileprivate func getCreateEthAddressRespone(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHolder = RevealAPISocketStubsHolder()
        let stubHolder = CreateEthAddressStubHolder()
        
        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let transferResponse = stubHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return transferResponse
        }
        
        return nil
    }
    
    fileprivate func getEthAddressRespone(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHolder = RevealAPISocketStubsHolder()
        let stubHolder = GetEthAddressStubHolder()
        
        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let transferResponse = stubHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return transferResponse
        }
        
        return nil
    }
    
    fileprivate func getWithdrawEthRespone(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHolder = RevealAPISocketStubsHolder()
        let stubHolder = WithdrawalEthStubHolder()
        
        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let transferResponse = stubHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return transferResponse
        }
        
        return nil
    }
    
    fileprivate func getAccountDepositsRespone(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHolder = RevealAPISocketStubsHolder()
        let stubHolder = GetAccountDepositsStubHolder()
        
        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let transferResponse = stubHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return transferResponse
        }
        
        return nil
    }
    
    fileprivate func getAccountWithdrawalsRespone(request: String) -> String? {
        
        guard let tuple = parceRequest(request: request) else {
            return nil
        }
        
        let revealHolder = RevealAPISocketStubsHolder()
        let stubHolder = GetAccountWithdrawalsStubHolder()
        
        if let revealResponse = revealHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return revealResponse
        } else if let transferResponse = stubHolder.response(id: tuple.id, operationType: tuple.operationType) {
            return transferResponse
        }
        
        return nil
    }
}

