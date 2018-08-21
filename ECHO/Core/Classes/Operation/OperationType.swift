//
//  OperationType.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 17.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

enum OperationType: Int {
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
    case committeeMemberUpdateGlobalParametersOperation
    case vestingBalanceCreateOperation
    case vestingBalanceWithdrawOperation
    case workerCreateOperation
    case customOperation
    case assertOperation
    case balanceClaimOperation
    case overrideTransferOperation
    case transferToBlindOperation
    case blindTransferOperation40
    case transferFromBlindOperation
    case assetSettleCancelOperation                  //Virtual
    case assetClaimFeesOperation
    case fbaDistributeOperation                      //Virtual
    case bidCollateralOperation
    case executeBidOperation                         //Virtual
    case contractOperation
    case contractTransferOperation                   //Virtual //48
    case callContractWithVerificationOperation       //49
}

struct OperationDecoder {
    
    func decode(_ operationId: Int, container: UnkeyedDecodingContainer) -> BaseOperation? {
        
        guard let type = OperationType(rawValue: operationId) else {
            return nil
        }
        
        switch type {
        case .accountCreateOperation: return decode(AccountCreateOperation.self, container: container)
        default: return nil
        }
    }
    
    fileprivate func decode<T>(_ type: T.Type, container: UnkeyedDecodingContainer) -> T? where T: Decodable {
        
        var container = container
        return try? container.decode(type)
    }
}
