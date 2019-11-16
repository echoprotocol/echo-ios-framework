//
//  AccountOptions.swift
//  ECHO
//
//  Created by Vladimir Sharaev on 17.08.2018.
//  Copyright © 2018 PixelPlex. All rights reserved.
//

/**
    Represents account options model in Graphene blockchain
 
    [AccountOptions model documentation](https://dev-doc.myecho.app/structgraphene_1_1chain_1_1account__options.html)
 */
public struct AccountOptions: ECHOCodable, Decodable {
    
    enum AccountOptionsCodingKeys: String, CodingKey {
        case extensions
        case delegatingAccount = "delegating_account"
        case delegateShare = "delegate_share"
    }
    
    let proxyToSelf = "1.2.5"
    
    let delegatingAccount: Account
    var delegateShare: Int = 0
    
    private var extensions = Extensions()
    
    init(delegatingAccount: Account?) {
        
        if let delegatingAccount = delegatingAccount {
            self.delegatingAccount = delegatingAccount
        } else {
            self.delegatingAccount = Account(proxyToSelf)
        }
    }
    
    public init(from decoder: Decoder) throws {

        let values = try decoder.container(keyedBy: AccountOptionsCodingKeys.self)
        
        let delegatingAccountIdString = try values.decode(String.self, forKey: .delegatingAccount)
        delegatingAccount = Account(delegatingAccountIdString)
    }
    
    // MARK: ECHOCodable
    
    public func toJSON() -> Any? {
        
        let dictionary: [AnyHashable: Any?] = [AccountOptionsCodingKeys.delegatingAccount.rawValue: delegatingAccount.id,
                                               AccountOptionsCodingKeys.delegateShare.rawValue: delegateShare,
                                               AccountOptionsCodingKeys.extensions.rawValue: extensions.toJSON()]
        
        return dictionary
    }
    
    public func toData() -> Data? {
        
        var data = Data()

        data.append(optional: delegatingAccount.toData())
        data.append(Data.fromInt16(delegateShare))
        data.append(optional: extensions.toData())
        
        return data
    }
}
