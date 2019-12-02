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
    case transferToAddressOperation
    case overrideTransferOperation
    case accountCreateOperation
    case accountUpdateOperation
    case accountWhitelistOperation
    case accountAddressCreateOperation
    case assetCreateOperation
    case assetUpdateOperation
    case assetUpdateBitassetOperation
    case assetUpdateFeedProducersOperation          //10
    case assetIssueOperation
    case assetReserveOperation
    case assetFundFeePoolOperation
    case assetPublishFeedOperation
    case assetClaimFeesOperaion
    case proposalCreateOperation
    case proposalUpdateOperation
    case proposalDeleteOperation
    case committeeMemberCreateOperation
    case committeeMemberUpdateOperation             //20
    // swiftlint:disable variable_name
    case committeeMemberUpdateGlobalParametersOperation
    // swiftlint:enable variable_name
    case committeeMemberActivateOperation
    case committeeMemberDeactivateOperation
    case committeeFrozenBalanceDepositOperation
    case committeeFrozenBalanceWithdrawOperation
    case vestingBalanceCreateOperation
    case vestingBalanceWithdrawOperation
    case balanceClaimOperation
    case balanceFreezeOperation
    case balanceUnfreezeOperation                   //30 // VIRTUAL
    case contractCreateOperation
    case contractCallOperation
    case contractInternalCreateOperation            // VIRTUAL
    case contractInternalCallOperation              // VIRTUAL
    case contractSelfdestructOperation              // VIRTUAL
    case contractUpdateOperation
    case contractFundPoolOperation
    case contractWhitelistOperation
    case sidechainETHCreateAddressOperation
    case sidechainETHApproveAddressOperation        //40
    case sidechainETHDepositOperation
    case sidechainETHWithdrawOperation
    case sidechainETHApproveWithdrawOperation
    case sidechainIssueOperation                 // VIRTUAL
    case sidechainBurnOperation                  // VIRTUAL
    case sidechainERC20RegisterTokenOperation
    case sidechainERC20DepositTokenOperation
    case sidechainERC20WithdrawTokenOperation
    // swiftlint:disable variable_name
    case sidechainERC20ApproveTokenWithdrawOperation
    // swiftlint:enable variable_name
    case sidechainERC20IssueOperation               //50 // VIRTUAL
    case sidechainERC20BurnOperation                // VIRTUAL
    case sidechainBTCCreateAddressOperation
    // swiftlint:disable variable_name
    case sidechainBTCCreateIntermediateDepositOperation
    // swiftlint:enable variable_name
    case sidechainBTCIntermediateDepositOperation
    case sidechainBTCDepositOperation
    case sidechainBTCWithdrawOperation
    case sidechainBTCApproveWithdrawOperation
    case sidechainBTCAggregateOperation
    case blockRewardOperation                       //59 // VIRTUAL
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
        case .contractInternalCallOperation: return decode(ContractInternalCallOperation.self, container: container)
        case .sidechainETHCreateAddressOperation: return decode(SidechainETHCreateAddressOperation.self, container: container)
        case .sidechainETHWithdrawOperation: return decode(SidechainETHWithdrawOperation.self, container: container)
        case .sidechainIssueOperation: return decode(SidechainIssueOperation.self, container: container)
        case .sidechainBurnOperation: return decode(SidechainBurnOperation.self, container: container)
        case .sidechainBTCCreateAddressOperation: return decode(SidechainBTCCreateAddressOperation.self, container: container)
        case .sidechainBTCWithdrawOperation: return decode(SidechainBTCWithdrawOperation.self, container: container)
        case .sidechainERC20RegisterTokenOperation: return decode(SidechainERC20RegisterTokenOperation.self, container: container)
        case .sidechainERC20WithdrawTokenOperation: return decode(SidechainERC20WithdrawTokenOperation.self, container: container)
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
            case .contractInternalCallOperation:
                baseOperation = try? JSONDecoder().decode(ContractInternalCallOperation.self, from: data)
            case .sidechainETHCreateAddressOperation:
                baseOperation = try? JSONDecoder().decode(SidechainETHCreateAddressOperation.self, from: data)
            case .sidechainETHWithdrawOperation:
                baseOperation = try? JSONDecoder().decode(SidechainETHWithdrawOperation.self, from: data)
            case .sidechainIssueOperation:
                baseOperation = try? JSONDecoder().decode(SidechainIssueOperation.self, from: data)
            case .sidechainBurnOperation:
                baseOperation = try? JSONDecoder().decode(SidechainBurnOperation.self, from: data)
            case .sidechainBTCCreateAddressOperation:
                baseOperation = try? JSONDecoder().decode(SidechainBTCCreateAddressOperation.self, from: data)
            case .sidechainBTCWithdrawOperation:
                baseOperation = try? JSONDecoder().decode(SidechainBTCWithdrawOperation.self, from: data)
            case .sidechainERC20RegisterTokenOperation:
                baseOperation = try? JSONDecoder().decode(SidechainERC20RegisterTokenOperation.self, from: data)
            case .sidechainERC20WithdrawTokenOperation:
                baseOperation = try? JSONDecoder().decode(SidechainERC20WithdrawTokenOperation.self, from: data)
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
