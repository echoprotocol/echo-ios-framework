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
        return """
                {"id":\(id),"jsonrpc":"2.0","result":[0,{"code":"6080604052600436106053576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680635b34b966146058578063a87d942c14606c578063f5c5ad83146094575b600080fd5b348015606357600080fd5b50606a60a8565b005b348015607757600080fd5b50607e60ba565b6040518082815260200191505060405180910390f35b348015609f57600080fd5b5060a660c3565b005b60016000808282540192505081905550565b60008054905090565b600160008082825403925050819055505600a165627a7a7230582063e27ea8b308defeeb50719f281e50a9b53ffa155e56f3249856ef7eafeb09e90029","storage":[["290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563",["00","01"]]]}]}
                """
    }
}

struct GetContractsSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "get_contracts"
    
    func createResponce(id: Int) -> String {
        return """
                {"id":\(id),"jsonrpc":"2.0","result":[{"id":"1.16.56","statistics":"2.20.36","destroyed":false,"type":"evm"}]}
                """
    }
}

struct GetAllContractsSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "get_all_contracts"
    
    func createResponce(id: Int) -> String {
        return """
                {"id":\(id),"jsonrpc":"2.0","result":[{"id":"1.16.0","statistics":"2.20.0","destroyed":false,"type":"evm"},{"id":"1.16.1","statistics":"2.20.1","destroyed":false,"type":"evm"},{"id":"1.16.2","statistics":"2.20.2","destroyed":false,"type":"evm"},{"id":"1.16.3","statistics":"2.20.3","destroyed":false,"type":"evm"},{"id":"1.16.4","statistics":"2.20.4","destroyed":false,"type":"evm"},{"id":"1.16.5","statistics":"2.20.5","destroyed":false,"type":"evm"},{"id":"1.16.6","statistics":"2.20.6","destroyed":false,"type":"evm"},{"id":"1.16.7","statistics":"2.20.7","destroyed":false,"type":"evm"},{"id":"1.16.8","statistics":"2.20.8","destroyed":false,"type":"evm"},{"id":"1.16.9","statistics":"2.20.9","destroyed":false,"type":"evm"}]}
                """
    }
}

struct GetAllContractResultSocketRequestElementStub: SocketRequestStub {
    
    var operationType = "get_contract_result"
    
    func createResponce(id: Int) -> String {
        return """
                    {"id":\(id),"jsonrpc":"2.0","result":[0,{"exec_res":{"excepted":"None","new_address":"0100000000000000000000000000000000000024","output":"6080604052600436106053576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680635b34b966146058578063a87d942c14606c578063f5c5ad83146094575b600080fd5b348015606357600080fd5b50606a60a8565b005b348015607757600080fd5b50607e60ba565b6040518082815260200191505060405180910390f35b348015609f57600080fd5b5060a660c3565b005b60016000808282540192505081905550565b60008054905090565b600160008082825403925050819055505600a165627a7a7230582063e27ea8b308defeeb50719f281e50a9b53ffa155e56f3249856ef7eafeb09e90029","code_deposit":"Success","gas_refunded":0,"gas_for_deposit":10924973,"deposit_size":257},"tr_receipt":{"status_code":1,"gas_used":126427,"bloom":"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000","log":[]}}]}
                """
    }
}
