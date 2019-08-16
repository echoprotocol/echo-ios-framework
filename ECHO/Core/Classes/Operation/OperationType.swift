//
//  OperationType.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 17.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
  Represents all blockchain operation types [Operations](https://dev-doc.myecho.app/group__operations.html#details)
 */
public enum OperationType: Int {
    case transferOperation                          //0
    case accountCreateOperation
    case accountUpdateOperation
    case accountWhitelistOperation
    case accountTransferOperation
    case assetCreateOperation
    case assetUpdateOperation
    case assetUpdateBitassetOperation
    case assetUpdateFeedProducersOperation
    case assetIssueOperation
    case assetReserveOperation                      //10
    case assetFundFeePoolOperation
    case assetPublishFeedOperation
    case proposalCreateOperation
    case proposalUpdateOperation
    case proposalDeleteOperation
    case committeeMemberCreateOperation
    case committeeMemberUpdateOperation
    // swiftlint:disable variable_name
    case committeeMemberUpdateGlobalParametersOperation
    // swiftlint:enable variable_name
    case vestingBalanceCreateOperation
    case vestingBalanceWithdrawOperation
    case balanceClaimOperation                      //20
    case overrideTransferOperation
    case assetClaimFeesOperation
    case contractCreateOperation
    case contractCallOperation
    case contractTransferOperation                  //Virtual
    case sidechainChangeConfigOperation             // temporary operation for tests
    case accountAddressCreateOperation
    case transferToAddressOperation
    case sidechainETHCreateAddressOperation
    case sidechainETHApproveAddressOperation        //30
    case sidechainETHDepositOperation
    case sidechainETHWithdrawOperation
    case sidechainETHApproveWithdrawOperation
    case contractFundPoolOperation
    case contractWhitelistOperation
    case sidechainETHIssueOperation                 // VIRTUAL
    case sidechainETHBurnOperation                  // VIRTUAL
    case sidechainERC20RegisterTokenOperation
    case sidechainERC20DepositTokenOperation
    case sidechainERC20WithdrawTokenOperation       //40
    case sidechainERC20ApproveTokenWithdrawOperation
    case contractUpdateOperation
}

struct OperationDecoder {
    
    func decode(_ operationId: Int, container: UnkeyedDecodingContainer) -> BaseOperation? {
        
        guard let type = OperationType(rawValue: operationId) else {
            return nil
        }
        
        switch type {
        case .accountCreateOperation: return decode(AccountCreateOperation.self, container: container)
        case .accountUpdateOperation: return decode(AccountUpdateOperation.self, container: container)
        case .transferOperation: return decode(TransferOperation.self, container: container)
        case .assetCreateOperation: return decode(CreateAssetOperation.self, container: container)
        case .assetIssueOperation: return decode(IssueAssetOperation.self, container: container)
        case .contractCreateOperation: return decode(CreateContractOperation.self, container: container)
        case .contractCallOperation: return decode(CallContractOperation.self, container: container)
        case .contractTransferOperation: return decode(ContractTransferOperation.self, container: container)
        case .sidechainETHCreateAddressOperation: return decode(SidechainETHCreateAddressOperation.self, container: container)
        case .sidechainETHWithdrawOperation: return decode(SidechainETHWithdrawOperation.self, container: container)
        case .sidechainETHIssueOperation: return decode(SidechainETHIssueOperation.self, container: container)
        case .sidechainETHBurnOperation: return decode(SidechainETHBurnOperation.self, container: container)
        default: return nil
        }
    }
    
    func decode(operations: [Any]) -> [BaseOperation] {
        
        var baseOperations = [BaseOperation]()
        
        for array in operations {
            
            guard let operation = array as? [Any] else { continue }
            guard let operationId = operation[safe: 0] as? Int else { continue }
            guard let type = OperationType(rawValue: operationId) else { continue }
            guard let operationDict = operation[safe: 1] as? [String: Any] else { continue }
            guard let data = try? JSONSerialization.data(withJSONObject: operationDict, options: []) else { continue }
            
            var baseOperation: BaseOperation?
            
            switch type {
            case .accountCreateOperation:
                baseOperation = try? JSONDecoder().decode(AccountCreateOperation.self, from: data)
            case .accountUpdateOperation:
                baseOperation = try? JSONDecoder().decode(AccountUpdateOperation.self, from: data)
            case .transferOperation:
                baseOperation = try? JSONDecoder().decode(TransferOperation.self, from: data)
            case .assetCreateOperation:
                baseOperation = try? JSONDecoder().decode(CreateAssetOperation.self, from: data)
            case .assetIssueOperation:
                baseOperation = try? JSONDecoder().decode(IssueAssetOperation.self, from: data)
            case .contractCreateOperation:
                baseOperation = try? JSONDecoder().decode(CreateContractOperation.self, from: data)
            case .contractCallOperation:
                baseOperation = try? JSONDecoder().decode(CallContractOperation.self, from: data)
            case .contractTransferOperation:
                baseOperation = try? JSONDecoder().decode(ContractTransferOperation.self, from: data)
            case .sidechainETHCreateAddressOperation:
                baseOperation = try? JSONDecoder().decode(SidechainETHCreateAddressOperation.self, from: data)
            case .sidechainETHWithdrawOperation:
                baseOperation = try? JSONDecoder().decode(SidechainETHWithdrawOperation.self, from: data)
            case .sidechainETHIssueOperation:
                baseOperation = try? JSONDecoder().decode(SidechainETHIssueOperation.self, from: data)
            case .sidechainETHBurnOperation:
                baseOperation = try? JSONDecoder().decode(SidechainETHBurnOperation.self, from: data)
            default:
                break
            }
            
            if let operation = baseOperation {
                baseOperations.append(operation)
            }
        }
        
        return baseOperations
    }
    
    fileprivate func decode<T>(_ type: T.Type, container: UnkeyedDecodingContainer) -> T? where T: Decodable {
        
        var container = container
        return try? container.decode(type)
    }
}
