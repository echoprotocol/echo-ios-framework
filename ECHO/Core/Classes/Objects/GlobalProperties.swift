//
//  GlobalProperties.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 26/02/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

public struct GlobalProperties: Decodable {
    
    private enum GlobalPropertiesCodingKeys: String, CodingKey {
        case identifier = "id"
        case parameters
        case nextAvailableVoteId = "next_available_vote_id"
        case activeCommitteeMembers = "active_committee_members"
        case activeWitnesses = "active_witnesses"
    }
    
    public let identifier: String
    public let parameters: GlobalPropertiesParameters
    public let nextAvailableVoteId: IntOrString
    public let activeCommitteeMembers: [String]
    public let activeWitnesses: [String]
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: GlobalPropertiesCodingKeys.self)
        
        identifier = try values.decode(String.self, forKey: .identifier)
        parameters = try values.decode(GlobalPropertiesParameters.self, forKey: .parameters)
        nextAvailableVoteId = try values.decode(IntOrString.self, forKey: .nextAvailableVoteId)
        activeCommitteeMembers = try values.decode([String].self, forKey: .activeCommitteeMembers)
        activeWitnesses = try values.decode([String].self, forKey: .activeWitnesses)
    }
}

public struct GlobalPropertiesParameters: Decodable {
    
    private enum GlobalPropertiesParametersCodingKeys: String, CodingKey {
        case currentFees = "current_fees"
        case blockInterval = "block_interval"
        case maintenanceInterval = "maintenance_interval"
        case maintenanceSkipSlots = "maintenance_skip_slots"
        case committeeProposalReviewPeriod = "committee_proposal_review_period"
        case maximumTransactionSize = "maximum_transaction_size"
        case maximumBlockSize = "maximum_block_size"
        case maximumTimeUntilExpiration = "maximum_time_until_expiration"
        case maximumProposalLifetime = "maximum_proposal_lifetime"
        case maximumAssetWhitelistAuthorities = "maximum_asset_whitelist_authorities"
        case maximumAssetFeedPublishers = "maximum_asset_feed_publishers"
        case maximumWitnessCount = "maximum_witness_count"
        case maximumCommitteeCount = "maximum_committee_count"
        case maximumAuthorityMembership = "maximum_authority_membership"
        case reservePercentOfFee = "reserve_percent_of_fee"
        case networkPercentOfFee = "network_percent_of_fee"
        case lifetimeReferrerPercentOfFee = "lifetime_referrer_percent_of_fee"
        case cashbackVestingPeriodSeconds = "cashback_vesting_period_seconds"
        case cashbackVestingThreshold = "cashback_vesting_threshold"
        case countNonMemberVotes = "count_non_member_votes"
        case allowNonMemberWhitelists = "allow_non_member_whitelists"
        case witnessPayPerBlock = "witness_pay_per_block"
        case workerBudgetPerDay = "worker_budget_per_day"
        case maxPredicateOpcode = "max_predicate_opcode"
        case feeLiquidationThreshold = "fee_liquidation_threshold"
        case accountsPerFeeScale = "accounts_per_fee_scale"
        case accountFeeScaleBitshifts = "account_fee_scale_bitshifts"
        case maxAuthorityDepth = "max_authority_depth"
        case echorandConfig = "echorand_config"
        case sidechainConfig = "sidechain_config"
        case gasPrice = "gas_price"
    }
    
    public let currentFees: CurrentFeesGlobalPropertiesParameters
    public let blockInterval: IntOrString
    public let maintenanceInterval: IntOrString
    public let maintenanceSkipSlots: IntOrString
    public let committeeProposalReviewPeriod: IntOrString
    public let maximumTransactionSize: IntOrString
    public let maximumBlockSize: IntOrString
    public let maximumTimeUntilExpiration: IntOrString
    public let maximumProposalLifetime: IntOrString
    public let maximumAssetWhitelistAuthorities: IntOrString
    public let maximumAssetFeedPublishers: IntOrString
    public let maximumWitnessCount: IntOrString
    public let maximumCommitteeCount: IntOrString
    public let maximumAuthorityMembership: IntOrString
    public let reservePercentOfFee: IntOrString
    public let networkPercentOfFee: IntOrString
    public let lifetimeReferrerPercentOfFee: IntOrString
    public let cashbackVestingPeriodSeconds: IntOrString
    public let cashbackVestingThreshold: IntOrString
    public let countNonMemberVotes: Bool
    public let allowNonMemberWhitelists: Bool
    public let witnessPayPerBlock: IntOrString
    public let workerBudgetPerDay: IntOrString
    public let maxPredicateOpcode: IntOrString
    public let feeLiquidationThreshold: IntOrString
    public let accountsPerFeeScale: IntOrString
    public let accountFeeScaleBitshifts: IntOrString
    public let maxAuthorityDepth: IntOrString
    public let echorandConfig: EchorandConfig
    public let sidechainConfig: SidechainConfig
    public let gasPrice: GasPriceGlobalProperties
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: GlobalPropertiesParametersCodingKeys.self)
        
        currentFees = try values.decode(CurrentFeesGlobalPropertiesParameters.self, forKey: .currentFees)
        blockInterval = try values.decode(IntOrString.self, forKey: .blockInterval)
        maintenanceInterval = try values.decode(IntOrString.self, forKey: .maintenanceInterval)
        maintenanceSkipSlots = try values.decode(IntOrString.self, forKey: .maintenanceSkipSlots)
        committeeProposalReviewPeriod = try values.decode(IntOrString.self, forKey: .committeeProposalReviewPeriod)
        maximumTransactionSize = try values.decode(IntOrString.self, forKey: .maximumTransactionSize)
        maximumBlockSize = try values.decode(IntOrString.self, forKey: .maximumBlockSize)
        maximumTimeUntilExpiration = try values.decode(IntOrString.self, forKey: .maximumTimeUntilExpiration)
        maximumProposalLifetime = try values.decode(IntOrString.self, forKey: .maximumProposalLifetime)
        maximumAssetWhitelistAuthorities = try values.decode(IntOrString.self, forKey: .maximumAssetWhitelistAuthorities)
        maximumAssetFeedPublishers = try values.decode(IntOrString.self, forKey: .maximumAssetFeedPublishers)
        maximumWitnessCount = try values.decode(IntOrString.self, forKey: .maximumWitnessCount)
        maximumCommitteeCount = try values.decode(IntOrString.self, forKey: .maximumCommitteeCount)
        maximumAuthorityMembership = try values.decode(IntOrString.self, forKey: .maximumAuthorityMembership)
        reservePercentOfFee = try values.decode(IntOrString.self, forKey: .reservePercentOfFee)
        networkPercentOfFee = try values.decode(IntOrString.self, forKey: .networkPercentOfFee)
        lifetimeReferrerPercentOfFee = try values.decode(IntOrString.self, forKey: .lifetimeReferrerPercentOfFee)
        cashbackVestingPeriodSeconds = try values.decode(IntOrString.self, forKey: .cashbackVestingPeriodSeconds)
        cashbackVestingThreshold = try values.decode(IntOrString.self, forKey: .cashbackVestingThreshold)
        countNonMemberVotes = try values.decode(Bool.self, forKey: .countNonMemberVotes)
        allowNonMemberWhitelists = try values.decode(Bool.self, forKey: .allowNonMemberWhitelists)
        witnessPayPerBlock = try values.decode(IntOrString.self, forKey: .witnessPayPerBlock)
        workerBudgetPerDay = try values.decode(IntOrString.self, forKey: .workerBudgetPerDay)
        maxPredicateOpcode = try values.decode(IntOrString.self, forKey: .maxPredicateOpcode)
        feeLiquidationThreshold = try values.decode(IntOrString.self, forKey: .feeLiquidationThreshold)
        accountsPerFeeScale = try values.decode(IntOrString.self, forKey: .accountsPerFeeScale)
        accountFeeScaleBitshifts = try values.decode(IntOrString.self, forKey: .accountFeeScaleBitshifts)
        maxAuthorityDepth = try values.decode(IntOrString.self, forKey: .maxAuthorityDepth)
        echorandConfig = try values.decode(EchorandConfig.self, forKey: .echorandConfig)
        sidechainConfig = try values.decode(SidechainConfig.self, forKey: .sidechainConfig)
        gasPrice = try values.decode(GasPriceGlobalProperties.self, forKey: .gasPrice)
    }
}

public struct CurrentFeesGlobalPropertiesParameters: Decodable {
    
    private enum CurrentFeesGlobalPropertiesCodingKeys: String, CodingKey {
        case parameters
        case scale
    }
    
    public let parameters: [[IntOrDict]]
    public let scale: IntOrString
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CurrentFeesGlobalPropertiesCodingKeys.self)
        
        parameters = try values.decode([[IntOrDict]].self, forKey: .parameters)
        scale = try values.decode(IntOrString.self, forKey: .scale)
    }
}

public struct EchorandConfig: Decodable {
    
    private enum EchorandConfigCodingKeys: String, CodingKey {
        case timeNet1mb = "_time_net_1mb"
        case timeNet256b = "_time_net_256b"
        case creatorCount = "_creator_count"
        case verifierCount = "_verifier_count"
        case okThreshold = "_ok_threshold"
        case maxBbaSteps = "_max_bba_steps"
        case gc1Delay = "_gc1_delay"
    }
    
    public let timeNet1mb: IntOrString
    public let timeNet256b: IntOrString
    public let creatorCount: IntOrString
    public let verifierCount: IntOrString
    public let okThreshold: IntOrString
    public let maxBbaSteps: IntOrString
    public let gc1Delay: IntOrString
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: EchorandConfigCodingKeys.self)
        
        timeNet1mb = try values.decode(IntOrString.self, forKey: .timeNet1mb)
        timeNet256b = try values.decode(IntOrString.self, forKey: .timeNet256b)
        creatorCount = try values.decode(IntOrString.self, forKey: .creatorCount)
        verifierCount = try values.decode(IntOrString.self, forKey: .verifierCount)
        okThreshold = try values.decode(IntOrString.self, forKey: .okThreshold)
        maxBbaSteps = try values.decode(IntOrString.self, forKey: .maxBbaSteps)
        gc1Delay = try values.decode(IntOrString.self, forKey: .gc1Delay)
    }
}

public struct SidechainConfig: Decodable {
    
    private enum SidechainConfigCodingKeys: String, CodingKey {
        case echoContractId = "echo_contract_id"
        case echoVoteMethod = "echo_vote_method"
        case echoSignMethod = "echo_sign_method"
        case echoTransferTopic = "echo_transfer_topic"
        case echoTransferReadyTopic = "echo_transfer_ready_topic"
        case ethContractAddress = "eth_contract_address"
        case ethCommitteeMethod = "eth_committee_method"
        case ethTransferTopic = "eth_transfer_topic"
    }
    
    public let echoContractId: String
    public let echoVoteMethod: String
    public let echoSignMethod: String
    public let echoTransferTopic: String
    public let echoTransferReadyTopic: String
    public let ethContractAddress: String
    public let ethCommitteeMethod: String
    public let ethTransferTopic: String
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: SidechainConfigCodingKeys.self)
        
        echoContractId = try values.decode(String.self, forKey: .echoContractId)
        echoVoteMethod = try values.decode(String.self, forKey: .echoVoteMethod)
        echoSignMethod = try values.decode(String.self, forKey: .echoSignMethod)
        echoTransferTopic = try values.decode(String.self, forKey: .echoTransferTopic)
        echoTransferReadyTopic = try values.decode(String.self, forKey: .echoTransferReadyTopic)
        ethContractAddress = try values.decode(String.self, forKey: .ethContractAddress)
        ethCommitteeMethod = try values.decode(String.self, forKey: .ethCommitteeMethod)
        ethTransferTopic = try values.decode(String.self, forKey: .ethTransferTopic)
    }
}

public struct GasPriceGlobalProperties: Decodable {
    
    private enum GasPriceGlobalPropertiesCodingKeys: String, CodingKey {
        case price
        case gasAmount = "gas_amount"
    }
    
    public let price: IntOrString
    public let gasAmount: IntOrString
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: GasPriceGlobalPropertiesCodingKeys.self)
        
        price = try values.decode(IntOrString.self, forKey: .price)
        gasAmount = try values.decode(IntOrString.self, forKey: .gasAmount)
    }
}