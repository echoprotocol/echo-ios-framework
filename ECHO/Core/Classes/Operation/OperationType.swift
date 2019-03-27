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
    case limitOrderCreateOperation
    case limitOrderCancelOperation
    case callOrderUpdateOperation
    case fillOrderOperation                         //Virtual
    case accountCreateOperation
    case accountUpdateOperation
    case accountWhitelistOperation
    case accountUpgradeOperation
    case accountTransferOperation
    case assetCreateOperation                       //10
    case assetUpdateOperation
    case assetUpdateBitassetOperation
    case assetUpdateFeedProducersOperation
    case assetIssueOperation
    case assetReserveOperation
    case assetFundFeePoolOperation
    case assetSettleOperation
    case assetGlobalSettleOperation
    case assetPublishFeedOperation
    case witnessCreateOperation                     //20
    case witnessUpdateOperation
    case proposalCreateOperation
    case proposalUpdateOperation
    case proposalDeleteOperation
    case withdrawPermissionCreateOperation
    case withdrawPermissionUpdateOperation
    case withdrawPermissionClaimOperation
    case withdrawPermissionDeleteOperation
    case committeeMemberCreateOperation
    case committeeMemberUpdateOperation             //30
    // swiftlint:disable variable_name
    case committeeMemberUpdateGlobalParametersOperation
    // swiftlint:enable variable_name
    case vestingBalanceCreateOperation
    case vestingBalanceWithdrawOperation
    case workerCreateOperation
    case customOperation
    case assertOperation
    case balanceClaimOperation
    case overrideTransferOperation
    case transferToBlindOperation
    case blindTransferOperation                     //40
    case transferFromBlindOperation
    case assetSettleCancelOperation                 //Virtual
    case assetClaimFeesOperation
    case fbaDistributeOperation                     //Virtual
    case bidCollateralOperation
    case executeBidOperation                        //Virtual
    case createContractOperation
    case callContractOperation
    case contractTransferOperation                  //Virtual
    case changeSidechainConfigOperation             // 50
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
        case .createContractOperation: return decode(CreateContractOperation.self, container: container)
        case .callContractOperation: return decode(CallContractOperation.self, container: container)
        case .contractTransferOperation: return decode(ContractTransferOperation.self, container: container)
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
            case .createContractOperation:
                baseOperation = try? JSONDecoder().decode(CreateContractOperation.self, from: data)
            case .callContractOperation:
                baseOperation = try? JSONDecoder().decode(CallContractOperation.self, from: data)
            case .contractTransferOperation:
                baseOperation = try? JSONDecoder().decode(ContractTransferOperation.self, from: data)
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
