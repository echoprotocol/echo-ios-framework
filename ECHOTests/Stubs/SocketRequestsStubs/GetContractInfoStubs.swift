//
//  GetContractInfoStubs.swift
//  ECHOTests
//
//  Created by Fedorenko Nikita on 10.09.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

struct GetContractInfoStubHodler: SocketRequestStubHodler {
    
    var requests: [SocketRequestStub] = [GetContractSocketRequestElementStub(),
                                         GetContractsSocketRequestElementStub(),
                                         GetAllContractsSocketRequestElementStub(),
                                         GetAllContractResultSocketRequestElementStub()]
}


struct GetContractSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "get_contract"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":{\"contract_info\":{\"id\":\"1.16.1\",\"statistics\":\"2.20.1\",\"suicided\":false},\"code\":\"\",\"storage\":[[\"0\",\"54\"]]}}"
    }
}

struct GetContractsSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "get_contracts"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":[{\"id\":\"1.16.1\",\"statistics\":\"2.20.1\",\"suicided\":false}]}"
    }
}

struct GetAllContractsSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "get_all_contracts"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":[{\"id\":\"1.16.0\",\"statistics\":\"2.20.0\",\"suicided\":false},{\"id\":\"1.16.1\",\"statistics\":\"2.20.1\",\"suicided\":false},{\"id\":\"1.16.2\",\"statistics\":\"2.20.2\",\"suicided\":false},{\"id\":\"1.16.3\",\"statistics\":\"2.20.3\",\"suicided\":false},{\"id\":\"1.16.4\",\"statistics\":\"2.20.4\",\"suicided\":false},{\"id\":\"1.16.5\",\"statistics\":\"2.20.5\",\"suicided\":false},{\"id\":\"1.16.6\",\"statistics\":\"2.20.6\",\"suicided\":false},{\"id\":\"1.16.7\",\"statistics\":\"2.20.7\",\"suicided\":false},{\"id\":\"1.16.8\",\"statistics\":\"2.20.8\",\"suicided\":false},{\"id\":\"1.16.9\",\"statistics\":\"2.20.9\",\"suicided\":false},{\"id\":\"1.16.10\",\"statistics\":\"2.20.10\",\"suicided\":false},{\"id\":\"1.16.11\",\"statistics\":\"2.20.11\",\"suicided\":false},{\"id\":\"1.16.12\",\"statistics\":\"2.20.12\",\"suicided\":false},{\"id\":\"1.16.13\",\"statistics\":\"2.20.13\",\"suicided\":false}]}"
    }
}

struct GetAllContractResultSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "get_contract_result"
    
    func createResponce(id: Int) -> String {
        return "{\"id\":\(id),\"jsonrpc\":\"2.0\",\"result\":{\"exec_res\":{\"excepted\":\"None\",\"new_address\":\"0000000000000000000000000000000000000000\",\"output\":\"\",\"code_deposit\":\"None\",\"gas_refunded\":\"0000000000000000000000000000000000000000000000000000000000000000\",\"deposit_size\":0,\"gas_for_deposit\":\"0000000000000000000000000000000000000000000000000000000000000000\"},\"tr_receipt\":{\"status_code\":\"1\",\"gas_used\":\"000000000000000000000000000000000000000000000000000000000000a291\",\"bloom\":\"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\",\"log\":[]}}}"
    }
}
