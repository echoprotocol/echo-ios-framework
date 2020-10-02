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
    case transferOperation                          // 0
    case transferToAddressOperation
    case overrideTransferOperation
    case accountCreateOperation
    case accountUpdateOperation
    case accountWhitelistOperation
    case accountAddressCreateOperation
    case assetCreateOperation
    case assetUpdateOperation
    case assetUpdateBitassetOperation
    case assetUpdateFeedProducersOperation          // 10
    case assetIssueOperation
    case assetReserveOperation
    case assetFundFeePoolOperation
    case assetPublishFeedOperation
    case assetClaimFeesOperaion
    case proposalCreateOperation
    case proposalUpdateOperation
    case proposalDeleteOperation
    case committeeMemberCreateOperation
    case committeeMemberUpdateOperation             // 20
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
    case balanceUnfreezeOperation                   // 30 // VIRTUAL
    case requestBalanceUnfreezeOperation
    case contractCreateOperation
    case contractCallOperation
    case contractInternalCreateOperation            // VIRTUAL
    case contractInternalCallOperation              // VIRTUAL
    case contractSelfdestructOperation              // VIRTUAL
    case contractUpdateOperation
    case contractFundPoolOperation
    case contractWhitelistOperation
    case sidechainETHCreateAddressOperation         // 40
    case sidechainETHApproveAddressOperation
    case sidechainETHDepositOperation
    case sidechainETHSendDepositOperation
    case sidechainETHWithdrawOperation
    case sidechainETHSendWithdrawOperation
    case sidechainETHApproveWithdrawOperation
    // swiftlint:disable variable_name
    case sidechainETHUpdateContractAddressOperation
    // swiftlint:enable variable_name
    case sidechainIssueOperation                    // VIRTUAL
    case sidechainBurnOperation                     // VIRTUAL
    case sidechainERC20RegisterTokenOperation       // 50
    case sidechainERC20DepositTokenOperation
    case sidechainERC20SendDepositTokenOperation
    case sidechainERC20WithdrawTokenOperation
    case sidechainERC20SendWithdrawTokenOperation
    // swiftlint:disable variable_name
    case sidechainERC20ApproveTokenWithdrawOperation
    // swiftlint:enable variable_name
    case sidechainERC20IssueOperation               // VIRTUAL
    case sidechainERC20BurnOperation                // VIRTUAL
    case sidechainBTCCreateAddressOperation
    // swiftlint:disable variable_name
    case sidechainBTCCreateIntermediateDepositOperation
    // swiftlint:enable variable_name
    case sidechainBTCIntermediateDepositOperation   // 60
    case sidechainBTCDepositOperation
    case sidechainBTCWithdrawOperation
    case sidechainBTCAggregateOperation
    case sidechainBTCApproveAggregateOperation
    case sidechainBTCBlockProcessOperation
    case blockRewardOperation                       // VIRTUAL
    case evmAddressRegisterOperation
    case didCreateOperation
    case didUpdateOperation
    case didDeleteOperation                         //70
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
        case .balanceClaimOperation: return decode(BalanceClaimOperation.self, container: container)
        case .balanceFreezeOperation: return decode(BalanceFreezeOperation.self, container: container)
        case .balanceUnfreezeOperation: return decode(BalanceUnfreezeOperation.self, container: container)
        case .requestBalanceUnfreezeOperation: return decode(RequestBalanceUnfreezeOperation.self, container: container)
        case .contractCreateOperation: return decode(CreateContractOperation.self, container: container)
        case .contractCallOperation: return decode(CallContractOperation.self, container: container)
        case .contractInternalCallOperation: return decode(ContractInternalCallOperation.self, container: container)
        case .blockRewardOperation: return decode(BlockRewardOperation.self, container: container)
        case .contractFundPoolOperation: return decode(ContractFundPoolOperation.self, container: container)
        case .sidechainETHCreateAddressOperation: return decode(SidechainETHCreateAddressOperation.self, container: container)
        case .sidechainETHDepositOperation: return decode(SidechainETHDepositOperation.self, container: container)
        case .sidechainETHWithdrawOperation: return decode(SidechainETHWithdrawOperation.self, container: container)
        case .sidechainETHApproveAddressOperation: return decode(SidechainETHApproveAddressOperation.self, container: container)
        case .sidechainIssueOperation: return decode(SidechainIssueOperation.self, container: container)
        case .sidechainBurnOperation: return decode(SidechainBurnOperation.self, container: container)
        case .sidechainBTCCreateAddressOperation: return decode(SidechainBTCCreateAddressOperation.self, container: container)
        case .sidechainBTCCreateIntermediateDepositOperation: return decode(SidechainBTCCreateIntermediateDepositOperation.self, container: container)
        case .sidechainBTCWithdrawOperation: return decode(SidechainBTCWithdrawOperation.self, container: container)
        case .sidechainERC20RegisterTokenOperation: return decode(SidechainERC20RegisterTokenOperation.self, container: container)
        case .sidechainERC20WithdrawTokenOperation: return decode(SidechainERC20WithdrawTokenOperation.self, container: container)
        case .sidechainERC20IssueOperation: return decode(SidechainERC20IssueOperation.self, container: container)
        case .sidechainERC20BurnOperation: return decode(SidechainERC20BurnOperation.self, container: container)
        case .sidechainERC20DepositTokenOperation: return decode(SidechainERC20DepositTokenOperation.self, container: container)
        default: return nil
        }
    }
    
    // swiftlint:disable function_body_length
    func decode(operations: [Any]) -> [BaseOperation] {
        
        var baseOperations = [BaseOperation]()
        let decoder = JSONDecoder()
        
        for array in operations {
            
            guard let operation = array as? [Any] else { continue }
            guard let operationId = operation[safe: 0] as? Int else { continue }
            guard let type = OperationType(rawValue: operationId) else { continue }
            guard let operationDict = operation[safe: 1] as? [String: Any] else { continue }
            guard let data = try? JSONSerialization.data(withJSONObject: operationDict, options: []) else { continue }
            
            var baseOperation: BaseOperation?
            
            switch type {
            case .accountCreateOperation:
                baseOperation = try? decoder.decode(AccountCreateOperation.self, from: data)
            case .accountUpdateOperation:
                baseOperation = try? decoder.decode(AccountUpdateOperation.self, from: data)
            case .transferOperation:
                baseOperation = try? decoder.decode(TransferOperation.self, from: data)
            case .assetCreateOperation:
                baseOperation = try? decoder.decode(CreateAssetOperation.self, from: data)
            case .assetIssueOperation:
                baseOperation = try? decoder.decode(IssueAssetOperation.self, from: data)
            case .balanceClaimOperation:
                baseOperation = try? decoder.decode(BalanceClaimOperation.self, from: data)
            case .balanceFreezeOperation:
                baseOperation = try? decoder.decode(BalanceFreezeOperation.self, from: data)
            case .balanceUnfreezeOperation:
                baseOperation = try? decoder.decode(BalanceUnfreezeOperation.self, from: data)
            case .requestBalanceUnfreezeOperation:
                baseOperation = try? decoder.decode(RequestBalanceUnfreezeOperation.self, from: data)
            case .contractCreateOperation:
                baseOperation = try? decoder.decode(CreateContractOperation.self, from: data)
            case .contractCallOperation:
                baseOperation = try? decoder.decode(CallContractOperation.self, from: data)
            case .contractInternalCallOperation:
                baseOperation = try? decoder.decode(ContractInternalCallOperation.self, from: data)
            case .sidechainETHCreateAddressOperation:
                baseOperation = try? decoder.decode(SidechainETHCreateAddressOperation.self, from: data)
            case .blockRewardOperation:
                baseOperation = try? decoder.decode(BlockRewardOperation.self, from: data)
            case .contractFundPoolOperation:
                baseOperation = try? decoder.decode(ContractFundPoolOperation.self, from: data)
            case .sidechainETHDepositOperation:
                baseOperation = try? decoder.decode(SidechainETHDepositOperation.self, from: data)
            case .sidechainETHWithdrawOperation:
                baseOperation = try? decoder.decode(SidechainETHWithdrawOperation.self, from: data)
            case .sidechainETHApproveAddressOperation:
                baseOperation = try? decoder.decode(SidechainETHApproveAddressOperation.self, from: data)
            case .sidechainIssueOperation:
                baseOperation = try? decoder.decode(SidechainIssueOperation.self, from: data)
            case .sidechainBurnOperation:
                baseOperation = try? decoder.decode(SidechainBurnOperation.self, from: data)
            case .sidechainBTCCreateAddressOperation:
                baseOperation = try? decoder.decode(SidechainBTCCreateAddressOperation.self, from: data)
            case .sidechainBTCCreateIntermediateDepositOperation:
                baseOperation = try? decoder.decode(SidechainBTCCreateIntermediateDepositOperation.self, from: data)
            case .sidechainBTCWithdrawOperation:
                baseOperation = try? decoder.decode(SidechainBTCWithdrawOperation.self, from: data)
            case .sidechainERC20RegisterTokenOperation:
                baseOperation = try? decoder.decode(SidechainERC20RegisterTokenOperation.self, from: data)
            case .sidechainERC20WithdrawTokenOperation:
                baseOperation = try? decoder.decode(SidechainERC20WithdrawTokenOperation.self, from: data)
            case .sidechainERC20IssueOperation:
                baseOperation = try? decoder.decode(SidechainERC20IssueOperation.self, from: data)
            case .sidechainERC20BurnOperation:
                baseOperation = try? decoder.decode(SidechainERC20BurnOperation.self, from: data)
            case .sidechainERC20DepositTokenOperation:
                baseOperation = try? decoder.decode(SidechainERC20DepositTokenOperation.self, from: data)
            default:
                break
            }
            
            if let operation = baseOperation {
                baseOperations.append(operation)
            }
        }
        
        return baseOperations
    }
    // swiftlint:enable function_body_length
    
    fileprivate func decode<T>(_ type: T.Type, container: UnkeyedDecodingContainer) -> T? where T: Decodable {
        
        var container = container
        return try? container.decode(type)
    }
}
