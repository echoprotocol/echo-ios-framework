//
//  SubscribeContractLogsDelegateStub.swift
//  ECHOTests
//
//  Created by Vladimir Sharaev on 28/03/2019.
//  Copyright © 2019 PixelPlex. All rights reserved.
//

import XCTest
@testable import ECHO

class SubscribeContractLogsDelegateStub: SubscribeContractLogsDelegate {
    
    var contractId = ""
    var delegateEvents = 0
    var rightDelegateEvents = 0
    let exp: XCTestExpectation
    
    init(exp: XCTestExpectation) {
        self.exp = exp
    }
    
    func didCreateLogs(logs: [ContractLogEnum]) {
        
        delegateEvents += 1
        
        var isRight = true
        for log in logs {
            let interpretator = AbiArgumentCoderImp()
            let type = AbiParameterType.contractAddress
            let outputs = [AbiFunctionEntries(name: "", typeString: type.description, type: type)]
            
            let address: String
            switch log {
            case .evm(let evmLog):
                address = evmLog.address
            case .x86:
                return
            }
            
            let values = try? interpretator.getValueTypes(string: address, outputs: outputs)
            
            guard let contractIdLastPart = values?[safe: 0]?.value as? String else {
                return                
            }
            
            let idString = ObjectType.contract.getFullObjectIdByLastPart(contractIdLastPart)
            if idString != contractId {
                isRight = false
            }
        }
        
        if isRight {
            rightDelegateEvents += 1
        }
        
        exp.fulfill()
    }
    
    func addSubscribe(contractId: String) {
        self.contractId = contractId
    }
    
    deinit {
        print("DEINIT")
    }
}
