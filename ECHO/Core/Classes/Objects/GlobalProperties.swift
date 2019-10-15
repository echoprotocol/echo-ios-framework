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
    }
    
    public let identifier: String
    public let parameters: GlobalPropertiesParameters
    public let nextAvailableVoteId: IntOrString
    public let activeCommitteeMembers: [String]
    
    public init(identifier: String,
                parameters: GlobalPropertiesParameters,
                nextAvailableVoteId: IntOrString,
                activeCommitteeMembers: [String]
                ) {
        
        self.identifier = identifier
        self.parameters = parameters
        self.nextAvailableVoteId = nextAvailableVoteId
        self.activeCommitteeMembers = activeCommitteeMembers
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: GlobalPropertiesCodingKeys.self)
        
        identifier = try values.decode(String.self, forKey: .identifier)
        parameters = try values.decode(GlobalPropertiesParameters.self, forKey: .parameters)
        nextAvailableVoteId = try values.decode(IntOrString.self, forKey: .nextAvailableVoteId)
        activeCommitteeMembers = try values.decode([String].self, forKey: .activeCommitteeMembers)
    }
}

public struct GlobalPropertiesParameters: Decodable {
    
    private enum GlobalPropertiesParametersCodingKeys: String, CodingKey {
        case currentFees = "current_fees"
        case maintenanceInterval = "maintenance_interval"
        case committeeProposalReviewPeriod = "committee_proposal_review_period"
        case maximumTransactionSize = "maximum_transaction_size"
        case maximumBlockSize = "maximum_block_size"
        case maximumTimeUntilExpiration = "maximum_time_until_expiration"
        case maximumProposalLifetime = "maximum_proposal_lifetime"
        case maximumAssetWhitelistAuthorities = "maximum_asset_whitelist_authorities"
        case maximumAssetFeedPublishers = "maximum_asset_feed_publishers"
        case maximumCommitteeCount = "maximum_committee_count"
        case maximumAuthorityMembership = "maximum_authority_membership"
        case reservePercentOfFee = "reserve_percent_of_fee"
        case networkPercentOfFee = "network_percent_of_fee"
        case maxPredicateOpcode = "max_predicate_opcode"
        case accountsPerFeeScale = "accounts_per_fee_scale"
        case accountFeeScaleBitshifts = "account_fee_scale_bitshifts"
        case maxAuthorityDepth = "max_authority_depth"
        case echorandConfig = "echorand_config"
        case sidechainConfig = "sidechain_config"
        case gasPrice = "gas_price"
    }
    
    public let currentFees: CurrentFeesGlobalPropertiesParameters
    public let maintenanceInterval: IntOrString
    public let committeeProposalReviewPeriod: IntOrString
    public let maximumTransactionSize: IntOrString
    public let maximumBlockSize: IntOrString
    public let maximumTimeUntilExpiration: IntOrString
    public let maximumProposalLifetime: IntOrString
    public let maximumAssetWhitelistAuthorities: IntOrString
    public let maximumAssetFeedPublishers: IntOrString
    public let maximumCommitteeCount: IntOrString
    public let maximumAuthorityMembership: IntOrString
    public let reservePercentOfFee: IntOrString
    public let networkPercentOfFee: IntOrString
    public let maxPredicateOpcode: IntOrString
    public let accountsPerFeeScale: IntOrString
    public let accountFeeScaleBitshifts: IntOrString
    public let maxAuthorityDepth: IntOrString
    public let echorandConfig: EchorandConfig
    public let sidechainConfig: SidechainConfig
    public let gasPrice: GasPriceGlobalProperties
    
    public init(currentFees: CurrentFeesGlobalPropertiesParameters,
                maintenanceInterval: IntOrString,
                maintenanceSkipSlots: IntOrString,
                committeeProposalReviewPeriod: IntOrString,
                maximumTransactionSize: IntOrString,
                maximumBlockSize: IntOrString,
                maximumTimeUntilExpiration: IntOrString,
                maximumProposalLifetime: IntOrString,
                maximumAssetWhitelistAuthorities: IntOrString,
                maximumAssetFeedPublishers: IntOrString,
                maximumCommitteeCount: IntOrString,
                maximumAuthorityMembership: IntOrString,
                reservePercentOfFee: IntOrString,
                networkPercentOfFee: IntOrString,
                maxPredicateOpcode: IntOrString,
                accountsPerFeeScale: IntOrString,
                accountFeeScaleBitshifts: IntOrString,
                maxAuthorityDepth: IntOrString,
                echorandConfig: EchorandConfig,
                sidechainConfig: SidechainConfig,
                gasPrice: GasPriceGlobalProperties) {
        
        self.currentFees = currentFees
        self.maintenanceInterval = maintenanceInterval
        self.committeeProposalReviewPeriod = committeeProposalReviewPeriod
        self.maximumTransactionSize = maximumTransactionSize
        self.maximumBlockSize = maximumBlockSize
        self.maximumTimeUntilExpiration = maximumTimeUntilExpiration
        self.maximumProposalLifetime = maximumProposalLifetime
        self.maximumAssetWhitelistAuthorities = maximumAssetWhitelistAuthorities
        self.maximumAssetFeedPublishers = maximumAssetFeedPublishers
        self.maximumCommitteeCount = maximumCommitteeCount
        self.maximumAuthorityMembership = maximumAuthorityMembership
        self.reservePercentOfFee = reservePercentOfFee
        self.networkPercentOfFee = networkPercentOfFee
        self.maxPredicateOpcode = maxPredicateOpcode
        self.accountsPerFeeScale = accountsPerFeeScale
        self.accountFeeScaleBitshifts = accountFeeScaleBitshifts
        self.maxAuthorityDepth = maxAuthorityDepth
        self.echorandConfig = echorandConfig
        self.sidechainConfig = sidechainConfig
        self.gasPrice = gasPrice
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: GlobalPropertiesParametersCodingKeys.self)
        
        currentFees = try values.decode(CurrentFeesGlobalPropertiesParameters.self, forKey: .currentFees)
        maintenanceInterval = try values.decode(IntOrString.self, forKey: .maintenanceInterval)
        committeeProposalReviewPeriod = try values.decode(IntOrString.self, forKey: .committeeProposalReviewPeriod)
        maximumTransactionSize = try values.decode(IntOrString.self, forKey: .maximumTransactionSize)
        maximumBlockSize = try values.decode(IntOrString.self, forKey: .maximumBlockSize)
        maximumTimeUntilExpiration = try values.decode(IntOrString.self, forKey: .maximumTimeUntilExpiration)
        maximumProposalLifetime = try values.decode(IntOrString.self, forKey: .maximumProposalLifetime)
        maximumAssetWhitelistAuthorities = try values.decode(IntOrString.self, forKey: .maximumAssetWhitelistAuthorities)
        maximumAssetFeedPublishers = try values.decode(IntOrString.self, forKey: .maximumAssetFeedPublishers)
        maximumCommitteeCount = try values.decode(IntOrString.self, forKey: .maximumCommitteeCount)
        maximumAuthorityMembership = try values.decode(IntOrString.self, forKey: .maximumAuthorityMembership)
        reservePercentOfFee = try values.decode(IntOrString.self, forKey: .reservePercentOfFee)
        networkPercentOfFee = try values.decode(IntOrString.self, forKey: .networkPercentOfFee)
        maxPredicateOpcode = try values.decode(IntOrString.self, forKey: .maxPredicateOpcode)
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
    
    public init(parameters: [[IntOrDict]],
                scale: IntOrString) {
        
        self.parameters = parameters
        self.scale = scale
    }
    
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
    
    public init(timeNet1mb: IntOrString,
                timeNet256b: IntOrString,
                creatorCount: IntOrString,
                verifierCount: IntOrString,
                okThreshold: IntOrString,
                maxBbaSteps: IntOrString,
                gc1Delay: IntOrString) {
        
        self.timeNet1mb = timeNet1mb
        self.timeNet256b = timeNet256b
        self.creatorCount = creatorCount
        self.verifierCount = verifierCount
        self.okThreshold = okThreshold
        self.maxBbaSteps = maxBbaSteps
        self.gc1Delay = gc1Delay
    }
    
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
        
        case ethContractAddress = "eth_contract_address"
        case ethCommitteeUpdateMethod = "eth_committee_update_method"
        case ethGenAddressMethod = "eth_gen_address_method"
        case ethWithdrawMethod = "eth_withdraw_method"
        case ethCommitteeUpdatedTopic = "eth_committee_updated_topic"
        case ethGenAddressTopic = "eth_gen_address_topic"
        case ethDepositTopic = "eth_deposit_topic"
        case ethWithdrawTopic = "eth_withdraw_topic"
        case erc20DepositTopic = "erc20_deposit_topic"
        case erc20WithdrawTopic = "erc20_withdraw_topic"
        case ethUpdateAddressMethod = "eth_update_addr_method"
        case ETHAssetId = "ETH_asset_id"
        case fines
        case waitingBlocks = "waiting_blocks"
        case gasPrice = "gas_price"
        case waitingETHBlocks = "waiting_eth_blocks"
    }
    
    public let ethContractAddress: String
    public let ethCommitteeUpdateMethod: EthMethod
    public let ethGenAddressMethod: EthMethod
    public let ethWithdrawMethod: EthMethod
    public let ethUpdateAddressMethod: EthMethod?
    public let ethCommitteeUpdatedTopic: String
    public let ethGenAddressTopic: String
    public let ethDepositTopic: String
    public let ethWithdrawTopic: String
    public let erc20DepositTopic: String
    public let erc20WithdrawTopic: String
    public let ETHAssetId: String
    public let fines: SidechainFines
    public let waitingBlocks: IntOrString
    public let gasPrice: IntOrString
    public let waitingETHBlocks: IntOrString
    
    public init(ethContractAddress: String,
                ethCommitteeUpdateMethod: EthMethod,
                ethGenAddressMethod: EthMethod,
                ethWithdrawMethod: EthMethod,
                ethUpdateAddressMethod: EthMethod?,
                ethCommitteeUpdatedTopic: String,
                ethGenAddressTopic: String,
                ethDepositTopic: String,
                ethWithdrawTopic: String,
                erc20DepositTopic: String,
                erc20WithdrawTopic: String,
                ETHAssetId: String,
                fines: SidechainFines,
                waitingBlocks: IntOrString,
                gasPrice: IntOrString,
                waitingETHBlocks: IntOrString) {
        
        self.ethContractAddress = ethContractAddress
        self.ethCommitteeUpdateMethod = ethCommitteeUpdateMethod
        self.ethGenAddressMethod = ethGenAddressMethod
        self.ethWithdrawMethod = ethWithdrawMethod
        self.ethUpdateAddressMethod = ethUpdateAddressMethod
        self.ethCommitteeUpdatedTopic = ethCommitteeUpdatedTopic
        self.ethGenAddressTopic = ethGenAddressTopic
        self.ethDepositTopic = ethDepositTopic
        self.ethWithdrawTopic = ethWithdrawTopic
        self.erc20DepositTopic = erc20DepositTopic
        self.erc20WithdrawTopic = erc20WithdrawTopic
        self.ETHAssetId = ETHAssetId
        self.fines = fines
        self.waitingBlocks = waitingBlocks
        self.gasPrice = gasPrice
        self.waitingETHBlocks = waitingETHBlocks
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: SidechainConfigCodingKeys.self)
        
        ethContractAddress = try values.decode(String.self, forKey: .ethContractAddress)
        ethCommitteeUpdateMethod = try values.decode(EthMethod.self, forKey: .ethCommitteeUpdateMethod)
        ethGenAddressMethod = try values.decode(EthMethod.self, forKey: .ethGenAddressMethod)
        ethWithdrawMethod = try values.decode(EthMethod.self, forKey: .ethWithdrawMethod)
        ethUpdateAddressMethod = try? values.decode(EthMethod.self, forKey: .ethUpdateAddressMethod)
        ethCommitteeUpdatedTopic = try values.decode(String.self, forKey: .ethCommitteeUpdatedTopic)
        ethGenAddressTopic = try values.decode(String.self, forKey: .ethGenAddressTopic)
        ethDepositTopic = try values.decode(String.self, forKey: .ethDepositTopic)
        ethWithdrawTopic = try values.decode(String.self, forKey: .ethWithdrawTopic)
        erc20DepositTopic = try values.decode(String.self, forKey: .erc20DepositTopic)
        erc20WithdrawTopic = try values.decode(String.self, forKey: .erc20WithdrawTopic)
        ETHAssetId = try values.decode(String.self, forKey: .ETHAssetId)
        fines = try values.decode(SidechainFines.self, forKey: .fines)
        waitingBlocks = try values.decode(IntOrString.self, forKey: .waitingBlocks)
        gasPrice = try values.decode(IntOrString.self, forKey: .gasPrice)
        waitingETHBlocks = try values.decode(IntOrString.self, forKey: .waitingETHBlocks)
    }
}

public struct SidechainFines: Decodable {
    
    private enum SidechainFinesCodingKeys: String, CodingKey {
        case generateETHAddress = "generate_eth_address"
    }
    
    public let generateETHAddress: Int
    
    public init(generateETHAddress: Int) {
        
        self.generateETHAddress = generateETHAddress
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: SidechainFinesCodingKeys.self)
        
        generateETHAddress = try values.decode(Int.self, forKey: .generateETHAddress)
    }
}

public struct EthMethod: Decodable {
    
    private enum EthMethodCodingKeys: String, CodingKey {
        case method
        case gas
    }
    
    public let method: String
    public let gas: IntOrString
    
    public init(method: String, gas: IntOrString) {
        
        self.method = method
        self.gas = gas
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: EthMethodCodingKeys.self)
        
        method = try values.decode(String.self, forKey: .method)
        gas = try values.decode(IntOrString.self, forKey: .gas)
    }
}

public struct GasPriceGlobalProperties: Decodable {
    
    private enum GasPriceGlobalPropertiesCodingKeys: String, CodingKey {
        case price
        case gasAmount = "gas_amount"
    }
    
    public let price: IntOrString
    public let gasAmount: IntOrString
    
    public init(price: IntOrString,
                gasAmount: IntOrString) {
        
        self.price = price
        self.gasAmount = gasAmount
    }
    
    public init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: GasPriceGlobalPropertiesCodingKeys.self)
        
        price = try values.decode(IntOrString.self, forKey: .price)
        gasAmount = try values.decode(IntOrString.self, forKey: .gasAmount)
    }
}
